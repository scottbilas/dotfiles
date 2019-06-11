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

function Install-UnityForProject($projectPath, $intoRoot = 'C:\builds\editor') {
    $version = Get-UnityFromProjectVersion $projectPath
    "Installing Unity $version into $intoRoot..."
    $version | %{ unity-downloader-cli -u $_ -p $intoRoot\$_ -c Editor -c StandaloneSupport-Mono -c StandaloneSupport-IL2CPP -c Symbols --wait }
}

function Open-DevSpace($what = (pwd), [switch]$Rider, [switch]$VS, [switch]$Code, [switch]$Unity, [switch]$Gitkraken) {




    # $what can be:
    #   folder (try to guess what we want, including walking up from current folder)
    #   .sln (extension optional)
    #   root of unity project

    # also print out a summary of what's happening, what branch we're on, whether it's on remote already, etc.
}

function Scobi-Do {
}

Export-ModuleMember Get-UnityFromProjectVersion

#Export-ModuleMember Open-UnityProject
#Export-ModuleMember Open-DevSpace
#Export-ModuleMember Scobi-Do
