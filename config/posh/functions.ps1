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
function Git-PurgeMergedUpstreamBranches($master = 'origin/master') {
#    if (!$master) {
#        # from https://stackoverflow.com/a/1418022/14582
#        $master = git rev-parse --abbrev-ref HEAD
#    }
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
# TODO: ^^^ this does not work for "rebase and merge" on github - still thinks old branch needs hang around
# will `hub sync` do it instead?

function Git-ConvertSubmoduleToSubtree($prefix, $conversionBranch = $null) {
    if (!(test-path .git)) {
        throw "Must be at git repo root"
    }

    $originalBranch = git rev-parse --abbrev-ref HEAD

    $submodule = (Parse-IniFile .gitmodules)."submodule `"$prefix`""
    if (!$submodule -or !$submodule.path -or !$submodule.url) {
        throw "Unable to find valid submodule $prefix in .gitmodules"
    }

    if (!$conversionBranch) {
        $conversionBranch = "subtree/$($prefix.replace('/', '_'))"
    }

    git rev-parse --verify $conversionBranch 2>&1 > $null
    if ($LASTEXITCODE) {
        git checkout -qb $conversionBranch
    }
    else {
        git checkout -q $conversionBranch
    }

    # https://stackoverflow.com/a/21211232/14582
    git submodule deinit -f $prefix
    rm -rf .git/modules/$prefix
    git rm -f $prefix
    git commit -m "Removal of submodule $prefix in prep for conversion to subtree"

    git -c submodule.recurse=false subtree add --squash -P $prefix $submodule.url (?? $submodule.branch master)

    git checkout $originalBranch
}

function Git-ConvertAllSubmodulesToSubtrees {
    git submodule status|%{ ($_ -split ' ')[2] } | %{
        Git-ConvertSubmoduleToSubtree $_ 'subtree/all'
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

function Sysinternals-Register {
    dir ~/scoop/apps/sysinternals/current/*.exe | %{ [io.path]::GetFileNameWithoutExtension($_) } | %{
        write-host -nonew "$_ "
        reg add HKCU\Software\Sysinternals\$_ /v EulaAccepted /t REG_DWORD /d 1 /f > $null
    }
    write-host
}
