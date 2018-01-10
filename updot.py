from os import environ
from sys import stderr
from updot import ln, mkdir, platform

# import argparse, argh, see
#   https://chase-seibert.github.io/blog/2014/03/21/python-multilevel-argparse.html
# import https://github.com/dbarnett/python-selfcompletion or argcomplete

# global options:
#   what-if
#   stop-on-first

def error(text):
    stderr.write(text)


PROJ                 = 'c:/proj'
APPDATA              = environ["APPDATA"]
SUBLIME_PACKAGE_ROOT = f'{APPDATA}/Sublime Text 3/Packages'

mkdir('~/bin')
mkdir('~/go/bin')

ln('~/dotfiles/config', '~/.config')
ln('~/Common/Private', '~/dotfiles/private')

mkdir('~/.ssh')
ln('~/dotfiles/private/ssh/authorized_keys', '~/.ssh/authorized_keys')

ln('~/.config/tmux/tmux.conf', '~/.tmux.conf') # tmux refuses to support xdg (https://github.com/tmux/tmux/issues/142)
ln(f'{PROJ}/unity-meta', '~/unity- X:os.name == 'nt'
    touchPOSIX . not WINDOWS

if platform.TERMUX:
    ln('~/.config/termux', '~/.termux')

if platform.WSL:
    ln('/mnt/c', '/c')

if platform.CYGWIN:
    ln('~/dotfiles/special/cygwin/profile', '~/.profile')
    ln('~/dotfiles/special/cygwin/minttyrc', '~/.minttyrc')
    ln('/cygdrive/c', '/c')

if platform.WINDOWS:
    ln('~/.config/git/config-windows',                 '~/.gitconfig')
    ln('~/.config/omnisharp',                          '~/.omnisharp')
    ln('~/dotfiles/special/vscode/User',              f'{APPDATA}/Code/User')
    ln('~/dotfiles/private/openvpn/config',            '~/OpenVPN/config')

    ln('~/Games/Factorio',                            f'{APPDATA}/Factorio')

    ln('~/Common/_Settings/gimp-2.8',                  '.gimp-2.8')
    ln('~/Common/_Settings/Ssh',                       '.ssh')
    ln('~/Common/_Settings/minttyrc.txt',              '.minttyrc')
    ln('~/Common/Visual Studio 2013',                  'Documents/Visual Studio 2013')
    ln('~/Common/Visual Studio 2015',                  'Documents/Visual Studio 2015')
    ln('~/Common/Visual Studio 2017',                  'Documents/Visual Studio 2017')
    ln('~/Common/WindowsPowerShell',                   'Documents/WindowsPowerShell')

    ln('~/unity-meta/Perforce Jam Language Files',    f'{SUBLIME_PACKAGE_ROOT}/Perforce Jam Language Files')
    ln('~/unity-meta/Unity bindings',                 f'{SUBLIME_PACKAGE_ROOT}/Unity bindings')


# registry

# vs code extensions

# visual studio keyboard settings

# parts of mc.ini and elinks configs that make sense to share
