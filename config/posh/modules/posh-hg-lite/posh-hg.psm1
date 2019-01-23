set-strictmode -version latest

# this module is a super minimal functionality hg status, where we don't even call hg.exe, which is
# ultra slow. until we have an hg equivalent of gitstatuscache, just can't do anything with hg.

# (note that some of this stuff was copied/adapted from posh-hg.)

function Get-HgDirectory {
    $pathInfo = Microsoft.PowerShell.Management\Get-Location
    if (!$pathInfo -or ($pathInfo.Provider.Name -ne 'FileSystem')) {
        $null
    }
    else {
        $currentDir = Get-Item -LiteralPath $pathInfo -Force
        while ($currentDir) {
            $hgDirPath = Join-Path $currentDir.FullName .hg
            if (Test-Path -LiteralPath $hgDirPath -PathType Container) {
                return $hgDirPath
            }

            $currentDir = $currentDir.Parent
        }
    }
}

function Get-HgStatus {
    param(
        [Parameter(Position=0)]
        $HgDir = (Get-HgDirectory)
    )

    if ($HgDir) {
        $branch = Get-Content $HgDir/branch

        New-Object PSObject -Property @{
            HgDir           = $HgDir
            RepoName        = Split-Path (Split-Path $HgDir -Parent) -Leaf
            Branch          = $branch
            AheadBy         = $null
            BehindBy        = $null
            UpstreamGone    = $null
            Upstream        = $branch
            HasIndex        = $false
            Index           = $null
            HasWorking      = $false
            Working         = $null
            HasUntracked    = $false
            StashCount      = $null
        }
    }
}

$exportModuleMemberParams = @{
    Function = @(
        'Get-HgDirectory'
        'Get-HgStatus'
    )
}

Export-ModuleMember @exportModuleMemberParams
