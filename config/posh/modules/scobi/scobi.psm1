$buildsEditorRoot = 'C:\builds\editor'

function Get-UnityFromProjectVersion($projectPath) {
    $projectVersionPath = join-path $projectPath 'ProjectSettings/ProjectVersion.txt'
    if (!(test-path $projectVersionPath)) {
        throw "Unable to find $projectVersionPath"
    }

    $version = type $projectVersionPath | ?{ $_ -match 'm_EditorVersion: (\S+)' } | %{ $Matches[1] }
    if (!$version) {
        throw "Unable to extract version number from $projectVersionPath"
    }
    $version
}

function Install-UnityForProject($projectPath, $intoRoot = $buildsEditorRoot) {
    $version = Get-UnityFromProjectVersion $projectPath
    "Installing Unity $version into $intoRoot..."
    $version | %{
        unity-downloader-cli -u $_ -p $intoRoot\$_ -c Editor -c StandaloneSupport-Mono -c StandaloneSupport-IL2CPP -c Symbols --wait
        # nuke the stripped symbols so vs doesn't use by accident
        del $intoRoot\$_\*.pdb
    }
}

function Get-UnityForProject($projectPath) {
    $version = Get-UnityFromProjectVersion $projectPath
    "$buildsEditorRoot\$version\unity.exe"
}

function Run-UnityForProject($projectPath = $null) {
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

    & (Get-UnityForProject $projectPath) -projectPath $projectPath
}

function Open-DevSpace($what = (pwd), [switch]$Rider, [switch]$VS, [switch]$Code, [switch]$Unity, [switch]$Gitkraken) {

    if ($Unity) {
        $version = Get-UnityFromProjectVersion $what
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

Export-ModuleMember Get-UnityFromProjectVersion
Export-ModuleMember Run-UnityForProject
Export-ModuleMember Install-UnityForProject
#Export-ModuleMember Open-DevSpace

#Export-ModuleMember Open-UnityProject
#Export-ModuleMember Scobi-Do
