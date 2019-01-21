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

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    $user = [System.Environment]::UserName
    $computer = [System.Environment]::MachineName.tolower()
    $path = Get-FullPath -dir $pwd
    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Prompt -Object "$user@$computer " -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
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
        $lastColor = $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object $($sl.PromptSymbols.SegmentForwardSymbol) -ForegroundColor $sl.Colors.PromptBackgroundColor -BackgroundColor $lastColor
        $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.Colors.GitForegroundColor
    }

    # Writes the postfix to the prompt
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor

    $timeStamp = Get-Date -UFormat %R
    $timestamp = "[$timeStamp]"

    $prompt += Set-CursorForRightBlockWrite -textLength ($timestamp.Length + 1)
    $prompt += Write-Prompt $timeStamp -ForegroundColor $sl.Colors.PromptForegroundColor

    $prompt += Set-Newline

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }
    $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator) -ForegroundColor $sl.Colors.PromptBackgroundColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings

$sl.PromptSymbols.FailedCommandSymbol = [char]0xe009
$sl.PromptSymbols.PromptIndicator = [char]0xfbad
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.PromptSymbols.StartSymbol = ''

$sl.Colors.GitForegroundColor = 'Black'
$sl.Colors.GitLocalChangesColor = 'Red'
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
