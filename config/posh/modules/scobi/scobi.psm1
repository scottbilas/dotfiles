$buildsEditorRoot = 'C:\builds\editor'

function Get-UnityVersionFromProjectVersion($projectPath, [switch]$getHash) {
    $projectVersionPath = join-path $projectPath 'ProjectSettings/ProjectVersion.txt'
    if (!(test-path $projectVersionPath)) {
        throw "Unable to find $projectVersionPath"
    }

    if ($getHash) {
        $version = type $projectVersionPath | ?{ $_ -match 'm_EditorVersionWithRevision: (\S+) \((\S+)\)' } | %{ $Matches[1], $Matches[2] }
    }
    else {
        $version = type $projectVersionPath | ?{ $_ -match 'm_EditorVersion: (\S+)' } | %{ $Matches[1] }
    }

    if (!$version) {
        throw "Unable to extract version number from $projectVersionPath"
    }

    $version
}

function Get-UnityVersionFromExe($exePath, [switch]$getHash) {
    if (!(test-path $exePath)) {
        throw "No Unity found at $exePath"
    }

    if ($getHash) {
        $version = (dir $exePath).versioninfo.comments -match '(\S+) \((\S+)\)' | %{ $Matches[1], $Matches[2] }
    }
    else {
        $version = (dir $exePath).versioninfo.comments -match '\S+' | %{ $Matches[0] }
    }

    if (!$version) {
        throw "Unity at $exePath has unexpected VERSIONINFO.Comments format"
    }

    $version
}

function Install-Unity($version, [switch]$minimal, $intoRoot = $buildsEditorRoot) {
    "Installing Unity $version into $intoRoot..."
    $version | %{
        if ($minimal) {
            unity-downloader-cli -u $_ -p $intoRoot\$_ -c Editor --wait
        }
        else {
            unity-downloader-cli -u $_ -p $intoRoot\$_ -c Editor -c StandaloneSupport-Mono -c StandaloneSupport-IL2CPP -c Symbols --wait
        }
        # nuke the stripped symbols so vs doesn't use by accident
        del $intoRoot\$_\*.pdb
    }
}

function Install-UnityForProject($projectPath, [switch]$minimal, $intoRoot = $buildsEditorRoot) {
    $version = Get-UnityVersionFromProjectVersion $projectPath
    Install-Unity -version $version -minimal:$minimal -intoroot $intoRoot
}

function Get-UnityBuildConfig($exePath) {
    # least awful option, given we don't store buildconfig in VERSIONINFO..just go by some kind of size threshold
    # https://unity.slack.com/archives/C07B85AE5/p1586853975112200?thread_ts=1586852005.107100&cid=C07B85AE5

    $filesize = (dir $exepath).length

    if ($filesize -gt 100MB -and $filesize -lt 150MB) {
        return 'release'
    }
    elseif ($filesize -gt 300MB -and $filesize -lt 400MB) {
        return 'debug'
    }

    throw 'Unexpected size for Unity exe, need to revise bounds'
}

function Get-UnityForProject($projectPath, [switch]$skipCustomBuild, [switch]$forceCustomBuild) {
    $version, $hash = Get-UnityVersionFromProjectVersion -getHash $projectPath
    $exePath = "$buildsEditorRoot\$version\unity.exe"

    $exeVersion, $exeHash = Get-UnityVersionFromExe -getHash $exePath
    if ($exeVersion -ne $version) {
        throw "Unity at $exePath has version $exeVersion, but was expecting $version"
    }

    if ($forceCustomBuild -and $skipCustomBuild) {
        throw "Wat you cannot force and skip"
    }

    $forcingCustomHash = $false
    if ($forceCustomBuild -or (!$skipCustomBuild -and $exeHash -ne $hash)) {
        foreach ($base in 'D:\work\unity', 'D:\work\unity2') {
            $customExe = join-path $base 'build\WindowsEditor\Unity.exe'
            if (test-path $customExe) {
                $customVersion, $customHash = Get-UnityVersionFromExe -getHash $customExe
                if ($customVersion -eq $version) {
                    if ($customHash -eq $hash) {
                        write-warning "Substituting custom build found with matching version/hash $customVersion/$customHash ($customExe)"
                        $exePath = $customExe
                        $exeHash = $customHash
                        break
                    }
                    elseif ($forceCustomBuild) {
                        write-warning "(forceCustomBuild=true) Substituting custom build found with same version but different hash $customVersion/$customHash ($customExe)"
                        $exePath = $customExe
                        $exeHash = $customHash
                        $forcingCustomHash = $true
                        break
                    }
                }
            }
        }
    }

    if (!$forcingCustomHash -and ($exeHash -ne $hash)) {
        write-warning "Found matching $exeVersion at $exePath, but unable to find exact hash $hash installed or in custom builds"
    }

    $buildConfig = get-unitybuildconfig $exePath
    if ($buildConfig -ne 'release') {
        write-warning "Running non-release build ($buildConfig) of Unity"
    }

    $exePath
}

function Run-UnityForProject($projectPath = $null, [switch]$skipCustomBuild, [switch]$forceCustomBuild, [switch]$useGlobalLogPath, [switch]$whatif) {
    if ($null -eq $projectPath)
    {
        $paths = dir -r -filter:ProjectSettings | % parent
        if ($paths.length -eq 1) {
            $projectPath = $paths[0]
        }
        else {
            "Found projects..."
            $paths | %{ "   $($_.name)"}
            return
        }
    }

    $projectPath = resolve-path $projectPath

    $extra = @()
    if (!$useGlobalLogPath) {
        $logPath = Join-Path $projectPath Logs
        $logFilename = Join-Path $logPath "$(split-path -leaf $projectPath)-Editor.log"
        $logFile = Get-ChildItem $logFilename -ea:silent
        if ($logFile) {
            $target = Join-Path $logPath ("Editor_{0:yyyyMMdd_HHMMss}.log" -f $logFile.LastWriteTime)
            Write-Verbose "Copying $logFile to $target"
            Copy-Item $logFile $target
        }

        $extra += '-logFile', $logFilename
    }

    # TODO: check to see if a unity already running for that path. either activate if identical to the one we want (and command line we want)
    # or abort if different with warnings.

    if ($whatif) {
        echo "$(Get-UnityForProject $projectPath -skipCustomBuild:$skipCustomBuild -forceCustomBuild:$forceCustomBuild) -projectPath $projectPath $extra"
    }
    else {
        $oldMixed = $Env:UNITY_MIXED_CALLSTACK
        try {
            $Env:UNITY_MIXED_CALLSTACK = 1
            & (Get-UnityForProject $projectPath -skipCustomBuild:$skipCustomBuild -forceCustomBuild:$forceCustomBuild) -projectPath $projectPath $extra
        }
        finally {
            $Env:UNITY_MIXED_CALLSTACK = $oldMixed
        }
    }
}

<# REDO THIS
function Open-DevSpace($what = (pwd), [switch]$Rider, [switch]$VS, [switch]$Code, [switch]$Unity, [switch]$Gitkraken) {

    if ($Unity) {
        $version = Get-UnityVersionFromProjectVersion $what
        $unityPath = [io.path]::Combine($buildsEditorRoot, $version, "unity.exe")
        if (!(test-path $unityPath)) {
            # auto-install
            throw "No Unity at $unityPath"
        }

        & $unitypath -projectPath $what
    }


    # $what can be:
    #   folder (try to guess what we want, including walking up from current folder)
    #   .sln (extension optional)
    #   root of unity project

    # also print out a summary of what's happening, what branch we're on, whether it's on remote already, etc.
}

function Scobi-Do {
}
#>

Export-ModuleMember Get-UnityVersionFromProjectVersion
Export-ModuleMember Get-UnityVersionFromExe
Export-ModuleMember Get-UnityForProject
Export-ModuleMember Run-UnityForProject
Export-ModuleMember Install-Unity
Export-ModuleMember Install-UnityForProject
#Export-ModuleMember Open-DevSpace

#Export-ModuleMember Open-UnityProject
#Export-ModuleMember Scobi-Do
