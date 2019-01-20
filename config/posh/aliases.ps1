#set-strictmode -version latest

# these aliases only cause problems
del alias:curl -fo -ea silent
del alias:wget -fo -ea silent
del alias:diff -fo -ea silent

# we never want to use `more` as a pager (and some things use it by default, like `help`)
set-alias more less

function l { get-childitemcolorformatwide $args }
function ll { dir -fo $args }
function ~ { cd ~ }
