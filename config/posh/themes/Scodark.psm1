#requires -Version 2 -Modules posh-git

Set-PSReadlineOption -AddToHistoryHandler {
    $script:LastCommandStart = get-date;
    Update-ZLocation $pwd
    $true
}

# this is copy-paste-adapted from the `paradox` theme
function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $now = get-date

    $lastColor = $sl.Colors.PromptBackgroundColor
    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

    $user = [System.Environment]::UserName
    $computer = [System.Environment]::MachineName.tolower()
    $computer += " $([char]0xf17a)"

    $path = Get-FullPath -dir $pwd

    $whoisFgColor = $sl.Colors.SessionInfoForegroundColor
    $whoisBgColor = $sl.Colors.SessionInfoBackgroundColor

    if (test-path env:SSH_CONNECTION) {
        $whoisFgColor = 'red'
    }

    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Prompt -Object "$user@$computer " -ForegroundColor $whoisFgColor -BackgroundColor $whoisBgColor
    }
    else {
        $prompt += Write-Prompt -Object "$computer " -ForegroundColor $whoisFgColor -BackgroundColor $whoisBgColor
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
    if ($path -eq '~') {
        $path = "$([char]0xf015)"
    }
    if ($path.startswith('~\')) {
        $path = "$([char]0xf015) $($sl.PromptSymbols.SegmentSeparatorForwardSymbol) $($path.substring(2))"
    }
    $prompt += Write-Prompt -Object "$path " -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        if ($status.gitdir) {
            $gitconfig = parse-inifile (join-path $status.gitdir 'config')
            $originurl = $gitconfig.'remote "origin"'.url
            if ($originurl | ss github) {
                $themeInfo.vcinfo = "$([char]0xf113) $($sl.PromptSymbols.SegmentSeparatorForwardSymbol) $($themeInfo.vcinfo)"
            }
            elseif ($originurl | ss gitlab) {
                $themeInfo.vcinfo = "$([char]0xf296) $($sl.PromptSymbols.SegmentSeparatorForwardSymbol) $($themeInfo.vcinfo)"
            }
        }
        elseif ($status.hgdir) {
            $themeInfo.vcinfo = $themeInfo.vcinfo.replace($sl.GitSymbols.BranchSymbol, [char]0xf223)
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

    $delay = ""
    if ($script:LastCommandStart) {

        $elapsed = $now - $script:LastCommandStart
        $script:LastCommandStart = $null

        if ($elapsed.TotalSeconds -gt 0.5) {
            if ($elapsed.TotalHours -ge 1) {
                $text = '{0}h{1:mm}m' -f $elapsed.hours, $elapsed
            }
            elseif ($elapsed.TotalMinutes -ge 1) {
                $text = '{0}m{1:ss}s' -f $elapsed.minutes, $elapsed
            }
            else {
                $text = $elapsed.totalseconds.tostring('0.00s')
            }

            $delay = "$($sl.PromptSymbols.SegmentSeparatorBackwardSymbol) $([char]0xfa1e)$text "
        }
    }

    $prompt += Set-CursorForRightBlockWrite -textLength ($delay.Length + $rightSide.Length)
    $prompt += Write-Prompt $delay -ForegroundColor 'Yellow'
    $prompt += Write-Prompt $rightSide -ForegroundColor 'White'

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

# IMPORTANT: this is all assuming the "One Dark" theme (via https://github.com/lukesampson/concfg)

$sl = $global:ThemeSettings #local settings

$sl.PromptSymbols.FailedCommandSymbol = [char]0xe009
$sl.PromptSymbols.PromptIndicator = [char]0xfbad
$sl.PromptSymbols.SegmentForwardSymbol = [char]0xe0b0
$sl.PromptSymbols.SegmentSeparatorForwardSymbol = [char]0xe0b1
$sl.PromptSymbols.SegmentBackwardSymbol = [char]0xe0b2
$sl.PromptSymbols.SegmentSeparatorBackwardSymbol = [char]0xe0b3
$sl.PromptSymbols.StartSymbol = ''

$sl.Colors.GitForegroundColor = 'Black'
$sl.Colors.GitLocalChangesColor = [ConsoleColor]::DarkYellow
$sl.Colors.PromptBackgroundColor = 'Blue'
$sl.Colors.PromptForegroundColor = 'Black'
$sl.Colors.PromptHighlightColor = 'DarkBlue'
$sl.Colors.PromptSymbolColor = 'White'
$sl.Colors.VirtualEnvBackgroundColor = 'Yellow'
$sl.Colors.VirtualEnvForegroundColor = 'Black'
$sl.Colors.WithBackgroundColor = 'Magenta'
$sl.Colors.WithForegroundColor = 'DarkRed'

$sl.GitSymbols.BranchIdenticalStatusToSymbol = $GitPromptSettings.BranchIdenticalStatusSymbol.Text
$sl.GitSymbols.BranchSymbol = [char]0xe725
$sl.GitSymbols.BranchUntrackedSymbol = '?'
$sl.GitSymbols.LocalWorkingStatusSymbol = [char]0xfbc2
$sl.GitSymbols.AfterStashSymbol = [char]0xf105
$sl.GitSymbols.BeforeStashSymbol = [char]0xf104
$sl.GitSymbols.BranchAheadStatusSymbol = [char]0xf55c
$sl.GitSymbols.BranchBehindStatusSymbol = [char]0xf544

$GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'
$GitPromptSettings.EnableStashStatus = $true
$GitPromptSettings.ShowStatusWhenZero = $false
$GitPromptSettings.FileModifiedText = [char]0xfc23

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

# powershell color improvements to match our theme
$Host.PrivateData.ProgressBackgroundColor = 'DarkGray'
$Host.PrivateData.ProgressForegroundColor = 'Yellow'
$Host.PrivateData.ErrorForegroundColor = 'Magenta'

# figure out how to modify LESS, or use .less to tune this color (which is unreadable by default in one-dark)
if (test-path env:LESS) {
    throw "Unexpected LESS"
}
#### interferes with git's `less` which doesn't support -D - find another way
#$env:LESS="-Ds13"
