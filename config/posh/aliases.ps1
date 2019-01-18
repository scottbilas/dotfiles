# these aliases only cause problems
remove-item alias:curl -force -ea silent
remove-item alias:wget -force -ea silent
remove-item alias:diff -force -ea silent

# we never want to use `more` as a pager (and some things use it by default, like `help`)
set-alias more less

set-alias l get-childitemcolorformatwide
function ll { get-childitemcolor $args -force }
