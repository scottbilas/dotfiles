from os import environ
from sys import stderr
from updot import ln, mkdir, platform

# import argparse, argh, see
#   https://chase-seibert.github.io/blog/2014/03/21/python-multilevel-argparse.html
# import https://github.com/dbarnett/python-selfcompletion or argcomplete

# global options:
#   what-if
#   stop-on-first
#   dev-level
#       bare [zsh, ssh, git, micro, man, elinks...]
#       basic [add python, vim, go, ruby...]
#       normal [all spec implemented]
#       full [everything ever detected as installed on any box is replicated]

def error(text):
    stderr.write(text)


# clean junk
rm('~/.bash_history')

mkdir('~/bin')
mkdir('~/go/bin')
env('GOPATH', '~/go')           # TODO: put in env.json or something. or possibly have env update and gen .ps1 and .sh files

ln('~/dotfiles/config', '~/.config')
ln('~/Common/Private', '~/dotfiles/private')

mkdir('~/.ssh')
#ln('~/dotfiles/private/ssh/authorized_keys', '~/.ssh/authorized_keys')
#^^ this gets bad permissions on termux, so use a cp() or sync() instead
mkdir('~/.cache/ssh/mux')

ln('~/.config/pdb/pdbrc.py', '~/.pdbrc.py', if_app='python')    # pdbpp uses fancycompleter which hard codes ~/<configname> and doesn't do xdg
ln('~/.config/hyper/hyper.js', '~/.hyper.js', if_app='hyper')   # lots of XDG arguments at https://github.com/zeit/hyper/issues/137

if platform.POSIX:
    touch('~/.hushlogin')
    ln('~/dotfiles/special/zsh/zshenv', '~/.zshenv') # http://zsh.org/mla/workers/2013/msg00692.html
    ln('~/.config/tmux/tmux.conf', '~/.tmux.conf', if_app='tmux')   # tmux refuses to support xdg (https://github.com/tmux/tmux/issues/142) TODO: switch to alias and use `-f`
    PROJ = '~/proj'
    # TODO ^ WORK = ~/work

if platform.TERMUX:
    sys('termux-setup-storage')
    ln('~/.config/termux', '~/.termux')
    ln('$PREFIX', '~/usr')
    ln('~/storage/shared/Sync/Common', '~/Common')
    # ^^^ do before ssh setup

if platform.WSL:
    ln('/mnt/c', '/c')
    PROJ = '/c/proj'

if platform.WINDOWS:
    APPDATA = environ["APPDATA"]

    ln('~/.config/git/config-windows', '~/.gitconfig')
    ln('~/.config/hg/hgrc', '~/.hgrc') # hg XDG code only runs under posix
    ln('~/.config/omnisharp', '~/.omnisharp')
    ln('~/dotfiles/special/vscode/User', f'{APPDATA}/Code/User')
    ln('~/dotfiles/private/openvpn/config', '~/OpenVPN/config')

    ln('~/Games/Factorio', f'{APPDATA}/Factorio')
    ln('~/Programs/Everything', f'{APPDATA}/Everything')

    # $$$ OUTDATED
    ln('~/Common/_Settings/gimp-2.8',                  '.gimp-2.8')
    ln('~/Common/_Settings/Ssh',                       '.ssh')
    ln('~/Common/_Settings/minttyrc.txt',              '.minttyrc')
    ln('~/Common/Visual Studio 2017',                  'Documents/Visual Studio 2017')
    ln('~/Common/WindowsPowerShell',                   'Documents/WindowsPowerShell')

    PROJ                 = 'c:/proj'
    # TODO: move the sublime-specific stuff to a 'helpers' module where can collect other similar goofy-lookup path methods
    SUBLIME_PACKAGE_ROOT = f'{APPDATA}/Sublime Text 3/Packages'

    ln('~/unity-meta/Perforce Jam Language Files',    f'{SUBLIME_PACKAGE_ROOT}/Perforce Jam Language Files')
    ln('~/unity-meta/Unity bindings',                 f'{SUBLIME_PACKAGE_ROOT}/Unity bindings')

    # XDG implementation on windows varies across tools. some fall back to ~/.config, some go to %localappdata%, some do
    # another thing entirely. so just manually set the root folder env vars and get it consistent.
    # TODO: `env` by default is the user env
    env('XDG_CONFIG_HOME', '~/.config', direxists=True)
    env('XDG_DATA_HOME', '~/.local/share')
    env('ChocolateyToolsLocation', R'~\choco')
    env(['TEMP', 'TMP'], R'c:\temp')
    env('UNITY_MIXED_CALLSTACK', '1', direxists=f'{PROJ}/unity')

    powershell("""
        . ~/scoop/apps/scoop/current/lib/core.ps1 # access to shim
        shim ~/DevBin/hg/hg.exe
        shim ~/DevBin/hg/thg.exe
    """)


ln(f'{PROJ}/unity-meta', '~/unity-meta')


## git submodule --init --recurse --jobs 3


# registry

# vs code extensions

# nvim :PlugInstall PlugUpgrade PlugUpdate UpdateRemotePlugins etc.
# nvim: create venv at ~/.local/share/nvim/venv and `pip install neovim pytest` into it

# micro plugin update

# visual studio keyboard settings

# sync scoop, choco, apt-get, npm, gem, pip

# parts of mc.ini and elinks configs that make sense to share

# update and re-build any repos we are manually managing (such as micro in gopath)

# zprezto-update

# dasht-docsets-update

# fzf
# git clone https://github.com/junegunn/fzf ~/.local/share/fzf
# ~/.local/share/fzf/install --bin
# ln -s ~/.local/share/fzf/bin/fzf ~/bin/fzf

# tmux plugin manager and updates
# note: need to <prefix>I (and then wait a while) for TPM to do initial setup
## we only need the initial tpm clone. after that, it will take care of
## updating its own repo. for now using a submodule, but in future would
## be better to just have updot ensure we have it in .local/share/tmux/plugins/tpm and after that completely leave unmanaged.
## so it makes sense to have clone() take a flag to say "do not autoupdate")
## or alternatively, tell it to keep .local/share/tmux/plugins/* up to date and then that can be part of the ordinary update rather than needing to tell tmux to do it.

# vim
# curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# ^^ windows: make sure the ~ is expanded, or make new 'curl' command that does it

# windows
# add-env-var PATH 'c:\users\scott\scoop\apps\git\current\mingw64\bin' << required for sshd git

# fix wsl to not add system path to debian path
# https://github.com/microsoft/WSL/issues/1493#issuecomment-417639271
# and https://github.com/microsoft/WSL/issues/1493#issuecomment-417690717
