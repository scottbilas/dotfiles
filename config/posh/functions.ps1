#set-strictmode -version latest

function reprofile {
    if ($myInvocation.InvocationName -ne '.') {
        throw 'You forgot to dot-source this (`. reprofile` <enter>)'
    }

    write-host 'Reloading aliases...'
    . "$($ProfileVars.ProfileRoot)\aliases.ps1"
    . ~/.config/posh/aliases.ps1

    write-host 'Reloading functions...'
    . "$($ProfileVars.ProfileRoot)\functions.ps1"
    . ~/.config/posh/functions.ps1
}

function install-nerd-fonts {
    scoop bucket add nerd-fonts
    sudo scoop install (dir ~\scoop\buckets\nerd-fonts\*.json | %{ $_.name.replace('.json', '') })
}

# from https://stackoverflow.com/a/422529/14582
Function Parse-IniFile ($file) {
    $ini = @{}

    # Create a default section if none exist in the file. Like a java prop file.
    $section = "NO_SECTION"
    $ini[$section] = @{}

    switch -regex -file $file {
        "^\[(.+)\]$" {
            $section = $matches[1].Trim()
            $ini[$section] = @{}
        }
        "^\s*([^#].+?)\s*=\s*(.*)" {
            $name, $value = $matches[1..2]
            # skip comments that start with semicolon:
            if (!($name.StartsWith(";"))) {
                $ini[$section][$name] = $value.Trim()
            }
        }
    }
    $ini
}

function Get-GitHub-Token {
    (parse-inifile ~/dotfiles/Private/keys/scott.toml).
        "'GitHub Personal Access Tokens'".
        'hub-cli'.
        replace("'","")
}

# scoop install hub busybox
function hub {
    env "GITHUB_TOKEN=$(Get-GitHub-Token)" hub @ARGS
}

# derived from https://github.com/not-an-aardvark/git-delete-squashed
function Git-PurgeMergedUpstreamBranches($master = $null) {
    if (!$master) {
        # from https://stackoverflow.com/a/1418022/14582
        $master = git rev-parse --abbrev-ref HEAD
    }
    foreach ($branch in (git for-each-ref refs/heads/ "--format=%(refname:short)")) {
        write-host -nonew "processing $branch..."
        $mergeBase = git merge-base $master $branch
        $status = (git cherry $master (git commit-tree (git rev-parse "$branch^{tree}") -p $mergeBase -m _))[0]
        write-host $status

        if ($status -eq '-') {
            write-host -nonew '   '
            git branch -D $branch
        }
    }
}

# derived from https://stackoverflow.com/a/54273949/14582
#
# proxy originally generated via:
# [management.automation.proxycommand]::create((new management.automation.commandmetadata(get-command select-object))) | oascii proxy.psm1
function s1 {
    [CmdletBinding(DefaultParameterSetName='DefaultParameter', HelpUri='https://go.microsoft.com/fwlink/?LinkID=113387', RemotingCapability='None')]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [psobject]
        ${InputObject},

        [Parameter(ParameterSetName='DefaultParameter', Position=0)]
        [System.Object[]]
        ${Property},

        [Parameter(ParameterSetName='DefaultParameter')]
        [string[]]
        ${ExcludeProperty},

        [Parameter(ParameterSetName='DefaultParameter')]
        [string]
        ${ExpandProperty},

        [switch]
        ${Unique},

        [Parameter(ParameterSetName='DefaultParameter')]
        [ValidateRange(0, 2147483647)]
        [int]
        ${Skip},

        [Parameter(ParameterSetName='IndexParameter')]
        [ValidateRange(0, 2147483647)]
        [int[]]
        ${Index})

    begin
    {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $PSBoundParameters.Add('First', '1')
        $PSBoundParameters.Add('Wait', $true)
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Select-Object', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    }

    process { $steppablePipeline.Process($_) }
    end { $steppablePipeline.End() }

    <#
    .ForwardHelpTargetName Microsoft.PowerShell.Utility\Select-Object
    .ForwardHelpCategory Cmdlet
    #>
}
function s10 {
    [CmdletBinding(DefaultParameterSetName='DefaultParameter', HelpUri='https://go.microsoft.com/fwlink/?LinkID=113387', RemotingCapability='None')]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [psobject]
        ${InputObject},

        [Parameter(ParameterSetName='DefaultParameter', Position=0)]
        [System.Object[]]
        ${Property},

        [Parameter(ParameterSetName='DefaultParameter')]
        [string[]]
        ${ExcludeProperty},

        [Parameter(ParameterSetName='DefaultParameter')]
        [string]
        ${ExpandProperty},

        [switch]
        ${Unique},

        [Parameter(ParameterSetName='DefaultParameter')]
        [ValidateRange(0, 2147483647)]
        [int]
        ${Skip},

        [Parameter(ParameterSetName='IndexParameter')]
        [ValidateRange(0, 2147483647)]
        [int[]]
        ${Index})

    begin
    {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $PSBoundParameters.Add('First', '10')
        $PSBoundParameters.Add('Wait', $true)
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Select-Object', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    }

    process { $steppablePipeline.Process($_) }
    end { $steppablePipeline.End() }

    <#
    .ForwardHelpTargetName Microsoft.PowerShell.Utility\Select-Object
    .ForwardHelpCategory Cmdlet
    #>
}
