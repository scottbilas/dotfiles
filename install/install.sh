#!/usr/bin/env bash

set -Eeuo pipefail

if [[ ! -e ~/dotfiles ]]; then
    if [[ ! $(type -p git) ]]; then
        sudo apt install git
    fi

    git clone --recursive https://github.com/scottbilas/dotfiles ~/dotfiles
fi
