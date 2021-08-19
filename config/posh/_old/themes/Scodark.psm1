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

    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

    $first = $true
    function Write-Segment($text, $fgcolor, $bgcolor) {
        $out = ""
        if (!$first) {
            if ($lastBgColor -ne $bgcolor) {
                $out += Write-Prompt $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastBgColor -BackgroundColor $bgcolor
            }
            else {
                $out += Write-Prompt $sl.PromptSymbols.SegmentSeparatorForwardSymbol -ForegroundColor $fgcolor -BackgroundColor $bgcolor
            }
        }
        set-variable -scope 1 lastBgColor $bgcolor
        set-variable -scope 1 first $false
        $out += Write-Prompt $text -ForegroundColor $fgcolor -BackgroundColor $bgcolor
        return $out
    }

    $now = get-date

    $user = [System.Environment]::UserName
    $computer = [System.Environment]::MachineName.tolower()
    $computer += " $([char]0xf17a)"

    $fullPath = $path = Get-FullPath -dir $pwd

    $whoisFgColor = $sl.Colors.SessionInfoForegroundColor
    $whoisBgColor = $sl.Colors.SessionInfoBackgroundColor

    if (test-path env:SSH_CONNECTION) {
        $whoisFgColor = $sl.Colors.SshSessionInfoForegroundColor
    }

    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Segment "$user@$computer " $whoisFgColor $whoisBgColor
    }
    else {
        $prompt += Write-Segment "$computer " $whoisFgColor $whoisBgColor
    }

    # Write the drive portion

    if ($path.startswith('~')) {
        $prompt += write-segment " $([char]0xf015) " $sl.Colors.PromptForegroundColor $sl.Colors.PromptBackgroundColor
        $path = $path -replace '^~[/\\]', ''
    }
    $prompt += write-segment " $path " $sl.Colors.PromptForegroundColor $sl.Colors.PromptBackgroundColor

    if (Test-VirtualEnv) {
        $prompt += write-segment " $($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " $sl.Colors.VirtualEnvForegroundColor $sl.Colors.VirtualEnvBackgroundColor
    }

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        if ($status.gitdir) {
            $configpath = join-path $status.gitdir 'config'
            if (test-path $configpath) {
                $gitconfig = parse-inifile $configpath
                $originurl = $gitconfig.'remote "origin"'.url
                if ($originurl | select-string github) {
                    $prompt += write-segment " $([char]0xf113) " $sl.Colors.GitForegroundColor $themeInfo.BackgroundColor
                }
                elseif ($originurl | select-string gitlab) {
                    $prompt += write-segment " $([char]0xf296) " $sl.Colors.GitForegroundColor $themeInfo.BackgroundColor
                }
            }
        }
        elseif ($status.hgdir) {
            $themeInfo.vcinfo = $themeInfo.vcinfo.replace($sl.GitSymbols.BranchSymbol, [char]0xf223)
        }

        $prompt += write-segment " $($themeInfo.VcInfo) " $sl.Colors.GitForegroundColor $themeInfo.BackgroundColor
    }

    # close left bar
    $prompt += write-segment ""

    $rightSide = "$($sl.PromptSymbols.SegmentSeparatorBackwardSymbol) $([char]0xf64f) {0}" -f (Get-Date -UFormat %R)

    $drive = (split-path $pwd -qualifier).replace(':','')
    if ((get-psdrive $drive).provider.name -eq 'FileSystem') {
        $freespace = (Get-CurrentDriveFreeSpace) / 1GB
        $rightSide = ("$($sl.PromptSymbols.SegmentSeparatorBackwardSymbol) $([char]0xf7c9) {0:0.0}GB " -f $freespace) + $rightSide
    }

    $delay = ""
    $delayLength = 0
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
            $delayLength = $delay.Length + 1
        }
    }

    $prompt += Set-CursorForRightBlockWrite -textLength ($delayLength + $rightSide.Length)
    $prompt += Write-Prompt $delay -ForegroundColor $sl.Colors.DelayForegroundColor
    $prompt += Write-Prompt $rightSide -ForegroundColor $sl.Colors.SessionInfoForegroundColor

    $prompt += Set-Newline

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    #check for elevated prompt
    $isAdmin = test-administrator
    If ($isAdmin) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }
    $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator) -ForegroundColor $sl.Colors.PromptSymbolColor
    $prompt += ' '
    $prompt

    if ($status.gitdir) {
        # main: gitdir = <reponame>/.git
        # worktree: gitdir = <main>/.git/worktrees/<reponame>
        $repoName = $status.gitdir
        if ((split-path -leaf $repoName) -eq '.git') {
            $repoName = split-path $repoName
        }
        $repoName = split-path -leaf $repoName

        $windowTitle = "$repoName [$($status.Branch)]"
    }
    elseif ($status.hgdir) {
        $repoName = $status.hgdir
        if ((split-path -leaf $repoName) -eq '.hg') {
            $repoName = split-path $repoName
        }
        $repoName = split-path -leaf $repoName

        $windowTitle = "$repoName [$($status.Branch)]"
    }
    else {
        $windowTitle = format-ellipsis $fullPath 30
    }

    if ($isAdmin) {
        $windowTitle = "$($sl.PromptSymbols.ElevatedSymbol) $windowTitle"
    }
    $Host.UI.RawUI.WindowTitle = $windowTitle
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

$sl.Colors.CommandFailedIconForegroundColor = '#c00000'
$sl.Colors.GitForegroundColor = 'Black'
$sl.Colors.GitLocalChangesColor = '#d19a66'
$sl.Colors.PromptBackgroundColor = '#61afef'
$sl.Colors.PromptForegroundColor = 'Black'
$sl.Colors.PromptHighlightColor = 'DarkBlue'
$sl.Colors.PromptSymbolColor = '#abb2bf'
$sl.Colors.VirtualEnvBackgroundColor = '#d000d0'
$sl.Colors.VirtualEnvForegroundColor = 'Black'
$sl.Colors.WithBackgroundColor = 'Magenta'
$sl.Colors.WithForegroundColor = 'DarkRed'
$sl.Colors.SshSessionInfoForegroundColor = 'Red'
$sl.Colors.DelayForegroundColor = 'DarkOrange'

$sl.GitSymbols.BranchIdenticalStatusToSymbol = $GitPromptSettings.BranchIdenticalStatusSymbol.Text
$sl.GitSymbols.BranchSymbol = [char]0xe725
$sl.GitSymbols.BranchUntrackedSymbol = [char]0xfb8e
$sl.GitSymbols.LocalWorkingStatusSymbol = [char]0xfbc2
$sl.GitSymbols.AfterStashSymbol = [char]0xf105
$sl.GitSymbols.BeforeStashSymbol = [char]0xf104
$sl.GitSymbols.BranchAheadStatusSymbol = [char]0xf55c
$sl.GitSymbols.BranchBehindStatusSymbol = [char]0xf544

$GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'
$GitPromptSettings.EnableStashStatus = $true
$GitPromptSettings.ShowStatusWhenZero = $false
$GitPromptSettings.FileModifiedText = [char]0xfc23

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
#$env:LESS += ' -Ds13'
