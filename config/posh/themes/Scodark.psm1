#requires -Version 2 -Modules posh-git

# this is copy-paste-adapted from the `paradox` theme
function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $lastColor = $sl.Colors.PromptBackgroundColor
    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

    $user = [System.Environment]::UserName
    $computer = [System.Environment]::MachineName.tolower()
    $path = Get-FullPath -dir $pwd
    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Prompt -Object "$user@$computer " -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }
    else {
        $prompt += Write-Prompt -Object "$computer " -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.VirtualEnvBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }
    else {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }

    # Writes the drive portion
    $prompt += Write-Prompt -Object "$path " -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        if ($status.gitdir) {
            $gitconfig = parse-inifile (join-path $status.gitdir 'config')
            $originurl = $gitconfig.'remote "origin"'.url
            if ($originurl | ss github) {
                $themeInfo.vcinfo = "$([char]0xf113) $($themeInfo.vcinfo)"
            }
            elseif ($originurl | ss gitlab) {
                $themeInfo.vcinfo = "$([char]0xf296) $($themeInfo.vcinfo)"
            }
        }
        $lastColor = $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object $($sl.PromptSymbols.SegmentForwardSymbol) -ForegroundColor $sl.Colors.PromptBackgroundColor -BackgroundColor $lastColor
        $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.Colors.GitForegroundColor
    }

    # Writes the postfix to the prompt
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor

    $rightSide = "$($sl.PromptSymbols.SegmentSeparatorBackwardSymbol) $([char]0xf64f) {0}" -f (Get-Date -UFormat %R)

    $drive = (split-path $pwd -qualifier).replace(':','')
    if ((get-psdrive $drive).provider.name -eq 'FileSystem') {
        $freespace = (free) / 1GB
        $rightSide = ("$($sl.PromptSymbols.SegmentSeparatorBackwardSymbol) $([char]0xf7c9) {0:0.0}GB " -f $freespace) + $rightSide
    }
    $rightSide = $rightSide

    $prompt += Set-CursorForRightBlockWrite -textLength ($rightSide.Length - 1)
    $prompt += Write-Prompt $rightSide -ForegroundColor 'Blue'

    $prompt += Set-Newline

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }
    $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator) -ForegroundColor $sl.Colors.PromptSymbolColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings

$sl.PromptSymbols.FailedCommandSymbol = [char]0xe009
$sl.PromptSymbols.PromptIndicator = [char]0xfbad
$sl.PromptSymbols.SegmentForwardSymbol = [char]0xe0b0
$sl.PromptSymbols.SegmentSeparatorForwardSymbol = [char]0xe0b1
$sl.PromptSymbols.SegmentBackwardSymbol = [char]0xe0b2
$sl.PromptSymbols.SegmentSeparatorBackwardSymbol = [char]0xe0b3
$sl.PromptSymbols.StartSymbol = ''

$sl.Colors.GitForegroundColor = 'Black'
$sl.Colors.GitLocalChangesColor = 'DarkYellow'
$sl.Colors.PromptBackgroundColor = 'Blue'
$sl.Colors.PromptForegroundColor = 'Black'
$sl.Colors.PromptHighlightColor = 'DarkBlue'
$sl.Colors.PromptSymbolColor = 'White'
$sl.Colors.VirtualEnvBackgroundColor = 'Yellow'
$sl.Colors.VirtualEnvForegroundColor = 'Black'
$sl.Colors.WithBackgroundColor = 'Magenta'
$sl.Colors.WithForegroundColor = 'DarkRed'

$sl.GitSymbols.BranchIdenticalStatusToSymbol = $GitPromptSettings.BranchIdenticalStatusSymbol.Text
$sl.GitSymbols.BranchUntrackedSymbol = '?'

$GitPromptSettings.WindowTitle = {
    param($GitStatus, $IsAdmin)
    "$(if ($IsAdmin) {'Admin: '})$(if ($GitStatus) {"$($GitStatus.RepoName) [$($GitStatus.Branch)]"} else {Get-PromptPath})"
}

# oh-my-posh will override these so set them back

# copy-paste from defaults in https://raw.githubusercontent.com/scottbilas/PSColor/master/release/PSColor.psm1
$PSColor.File = @{
    Default    = @{ Color = 'White' }
    Directory  = @{ Color = 'Cyan' }
    BrokenLink = @{ Color = 'DarkRed' }
    Hidden     = @{ Color = 'DarkGray'; Pattern = '^\.' }
    Custom = @{
        Code       = @{ Color = 'Magenta'; Pattern = '\.(java|c|cpp|cs|js|css|html)$' }
        Executable = @{ Color = 'Red'; Pattern = '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg)$' }
        Text       = @{ Color = 'Yellow'; Pattern = '\.(txt|cfg|conf|ini|csv|log|config|xml|yml|md|markdown)$' }
        Compressed = @{ Color = 'Green'; Pattern = '\.(zip|tar|gz|rar|jar|war|7z)$' }
    }
}

# actually custom for our theme
$PSColor.File.Hidden.Color = 'DarkBlue'
$PSColor.File.Directory.Color = 'Gray'
