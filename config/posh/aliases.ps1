#set-strictmode -version latest

function realias {
    write-host 'Reloading aliases...'
    . "$($ProfileVars.ProfileRoot)\aliases.ps1"
}

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

# we never want to use `more` as a pager (and some things use it by default, like `help`)
set-alias more less

set-alias g git

function l { get-childitemcolorformatwide $args }
function ll { dir -fo $args }
function ~ { cd ~ }

# https://stackoverflow.com/a/1663623/14582

function free {gdr -psp 'FileSystem'}

# this resets conemu to start printing ansi colors again (https://conemu.github.io/en/AnsiEscapeCodes.html#Example_3_scroll_console_to_bottom)
nuke-alias cls
function cls { "$([char]0x1b)c$([char]0x1b)[9999H" }

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

