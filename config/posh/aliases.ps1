#set-strictmode -version latest

function realias {
    write-host 'Reloading aliases...'
    . "$($ProfileVars.ProfileRoot)\aliases.ps1"
}

# these aliases only cause problems
del alias:curl -fo -ea silent
del alias:wget -fo -ea silent
del alias:diff -fo -ea silent

# we never want to use `more` as a pager (and some things use it by default, like `help`)
set-alias more less

set-alias g git

function l { get-childitemcolorformatwide $args }
function ll { dir -fo $args }
function ~ { cd ~ }

del alias:cls -fo -ea silent
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

