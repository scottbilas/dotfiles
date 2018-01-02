from os import environ
from sys import stderr
from updot import symlinks

# import argparse, argh, see
#   https://chase-seibert.github.io/blog/2014/03/21/python-multilevel-argparse.html
# import https://github.com/dbarnett/python-selfcompletion or argcomplete

# global options:
#   what-if
#   stop-on-first

def error(text):
    stderr.write(text)

WINDOWS              = 1 # DETECT
PROJ                 = 'c:/proj'
APPDATA              = environ["APPDATA"]
SUBLIME_PACKAGE_ROOT = f'{APPDATA}/Sublime Text 3/Packages'

u.mkdir('~/bin')
u.mkdir('~/go/bin')

u.symlink('~/Common/Private', '~/dotfiles/private')
ln -s ~/dotfiles/config ~/.config
mkdir ~/.ssh
ln -s ~/dotfiles/private/ssh/authorized_keys ~/.ssh/authorized_keys
ln -s ~/.config/tmux/tmux.conf ~/.tmux.conf
touch ~/.hushlogin

# termux only
ln -s ~/dotfiles/config/termux ~/.termux

# cygwin only
ln -s ~/dotfiles/special/cygwin/profile ~/.profile
ln -s ~/dotfiles/special/cygwin/minttyrc ~/.minttyrc

u.symlink('/mnt/c', '/c')
u.symlink('/cygdrive/c', '/c')

u.symlink(f'{PROJ}/unity-meta', '~/unity-meta')

if WINDOWS:
    u.symlink('~/.config/git/config-windows',                 '~/.gitconfig')
    u.symlink('~/.config/omnisharp',                          '~/.omnisharp')
    u.symlink('~/dotfiles/special/vscode/User',              f'{APPDATA}/Code/User')
    u.symlink('~/dotfiles/private/openvpn/config',            '~/OpenVPN/config')

    u.symlink('~/Games/Factorio',                            f'{APPDATA}/Factorio')

    u.symlink('~/Common/_Settings/gimp-2.8',                  '.gimp-2.8')
    u.symlink('~/Common/_Settings/Ssh',                       '.ssh')
    u.symlink('~/Common/_Settings/minttyrc.txt',              '.minttyrc')
    u.symlink('~/Common/Visual Studio 2013',                  'Documents/Visual Studio 2013')
    u.symlink('~/Common/Visual Studio 2015',                  'Documents/Visual Studio 2015')
    u.symlink('~/Common/Visual Studio 2017',                  'Documents/Visual Studio 2017')
    u.symlink('~/Common/WindowsPowerShell',                   'Documents/WindowsPowerShell')

    u.symlink('~/unity-meta/Perforce Jam Language Files',    f'{SUBLIME_PACKAGE_ROOT}/Perforce Jam Language Files')
    u.symlink('~/unity-meta/Unity bindings',                 f'{SUBLIME_PACKAGE_ROOT}/Unity bindings')


# registry

# vs code extensions

# visual studio keyboard settings

# parts of mc.ini and elinks configs that make sense to share
