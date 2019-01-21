#set-strictmode -version latest

function install-nerd-fonts {
    scoop bucket add nerd-fonts
    sudo scoop install (dir ~\scoop\buckets\nerd-fonts\*.json | %{ $_.name.replace('.json', '') })
}
