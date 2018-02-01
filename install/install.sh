#!/usr/bin/env bash

# This script installs scottbilas's dotfiles to a basic level under bash.
#
# Install:
#    `curl https://raw.githubusercontent.com/scottbilas/dotfiles/master/install/install.sh | bash`

set -Eeuo pipefail

if [[ ! -e ~/dotfiles ]]; then
    if [[ ! $(type -p git) ]]; then
        sudo apt install git
    fi

    git clone -b master --recursive https://github.com/scottbilas/dotfiles ~/dotfiles
fi
