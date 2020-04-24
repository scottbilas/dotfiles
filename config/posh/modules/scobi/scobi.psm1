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

function Get-UnityForProject($projectPath, [switch]$skipCustomBuild) {
    $version, $hash = Get-UnityVersionFromProjectVersion -getHash $projectPath
    $exePath = "$buildsEditorRoot\$version\unity.exe"

    $exeVersion, $exeHash = Get-UnityVersionFromExe -getHash $exePath
    if ($exeVersion -ne $version) {
        throw "Unity at $exePath has version $exeVersion, but was expecting $version"
    }

    if (!$skipCustomBuild -and $exeHash -ne $hash) {
        foreach ($base in 'D:\work\unity', 'D:\work\unity2') {
            $customExe = join-path $base 'build\WindowsEditor\Unity.exe'
            if (test-path $customExe) {
                $customVersion, $customHash = Get-UnityVersionFromExe -getHash $customExe
                if ($customVersion -eq $version -and $customHash -eq $hash) {
                    write-warning "Substituting custom build found with matching version/hash $customVersion/$customHash ($customExe)"
                    $exePath = $customExe
                    $exeHash = $customHash
                    break
                }
            }
        }
    }

    if ($exeHash -ne $hash) {
        write-warning "Found matching $exeVersion at $exePath, but unable to find exact hash $hash installed or in custom builds"
    }

    $buildConfig = get-unitybuildconfig $exePath
    if ($buildConfig -ne 'release') {
        write-warning "Running non-release build ($buildConfig) of Unity"
    }

    $exePath
}

function Run-UnityForProject($projectPath = $null, [switch]$skipCustomBuild, [switch]$useGlobalLogPath) {
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

    $extra = @()
    if (!$useGlobalLogPath) {
        $logPath = Join-Path (resolve-path $projectPath) Logs
        $logFilename = Join-Path $logPath Editor.log
        $logFile = Get-ChildItem $logFilename -ea:silent
        if ($logFile) {
            $target = Join-Path $logPath ("Editor_{0:yyyyMMdd_HHMMss}.log" -f $logFile.LastWriteTime)
            Write-Verbose "Copying $logFile to $target"
            Copy-Item $logFile $target
        }

        $extra += '-logFile', $logFilename
    }

    # check to see if unity already running there

    & (Get-UnityForProject $projectPath -skipCustomBuild:$skipCustomBuild) -projectPath $projectPath $extra
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
