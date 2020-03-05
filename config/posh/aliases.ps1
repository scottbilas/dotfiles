#set-strictmode -version latest

function nuke-alias($name) {
    # remove from every scope
    # https://stackoverflow.com/a/24743647/14582
    while (test-path alias:$name) {
        del -force alias:$name
    }
}

# these aliases only cause problems
nuke-alias curl
nuke-alias wget
nuke-alias diff
nuke-alias rm
nuke-alias set
nuke-alias sort

# always use the installed sort
set-alias sort (resolve-path ~\scoop\apps\git\current\usr\bin\sort.exe)

# we never want to use `more` as a pager (and some things use it by default, like `help`)
set-alias more less

set-alias g git
set-alias m micro

set-alias unity Run-UnityForProject

function l {
    if ($ProfileVars.IsConsoleHost) {
        get-childitemcolorformatwide $args
    }
    else {
        ll
    }
}

function ll { dir -fo $args }
function ~ { cd ~ }

# https://stackoverflow.com/a/1663623/14582

function free {gdr -psp 'FileSystem'}

# this resets conemu to start printing ansi colors again (https://conemu.github.io/en/AnsiEscapeCodes.html#Example_3_scroll_console_to_bottom)
nuke-alias cls
function cls {
    if ($ProfileVars.IsConEmu) {
        "$([char]0x1b)c$([char]0x1b)[9999H"
    }
    else {
        clear-host
    }
}

function theme {
    $theme = (split-path -leaf $ThemeSettings.CurrentThemeLocation).replace('.psm1', '')
    write-host "Reloading $theme..."
    set-theme $theme
}

function gk($repo = $null) {
    if (!$repo) { $repo = (pwd) }
    & $env:localappdata\gitkraken\update.exe --processStart gitkraken.exe --process-start-args="-p $repo"
}

function up { cd .. }
function upp { cd ../.. }
function uppp { cd ../../.. }
function upppp { cd ../../../.. }
function ov($what) { cd ../$what }


# disable for now.. what we want is the pager to show lines live as they come through, and when more than a full page is received,
# go into full screen less mode (and continue grepping in background)
#function rg { & (which rg) $args |less }
