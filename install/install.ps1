#requires -v 3

# This script installs scottbilas's dotfiles to a basic level under Powershell on Windows.
#
# Install:
#    `iwr https://raw.githubusercontent.com/scottbilas/dotfiles/master/install/install.ps1 -usebasic | iex`

$erroractionpreference = 'stop'

if (!(test-path ~/dotfiles)) {
    if (!(which git)) {
        iwr https://get.scoop.sh -useb | iex
        scoop install git
    }

    git clone -b master --recursive https://github.com/scottbilas/dotfiles "$(resolve-path ~)/dotfiles"
}

# further:
#  * any crucial symlinks, especially ssh-related and `private`
#  * fix git remotes
#  * updot
#  * scoop bucket extras, sudo, etc.
#
# consider putting ^ into a finishing py script
#  ...python seems a tolerable dependency, though i want 3.6 and it can be a hassle to ensure this is installed on trusty etc.
#  ...also want ssh option for containers that doesn't involve uploading private key, but typing in password instead
#  ...possible separation of "private" (crown jewels like ssh key) from "non-public" (personal email addrs and hosts, unity-isms)
#     where private accessed via password, everything else fine to copy in, just not via public GH repo
