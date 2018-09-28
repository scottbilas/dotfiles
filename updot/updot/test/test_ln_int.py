# this file contains high level integration tests for `ln`

import pytest
from pytest import raises

from testutils import HOME, expand
from testutils import links_db # pylint: disable=unused-import
from updot import exceptions, platform
from updot.links import ln


def test__basic_integration_scenario__succeeds(links_db):

    #|

#    mkdir('~/bin')
#    mkdir('~/go/bin')
#    mkdir('~/.ssh')

    PROJ = '~/proj'

    ln('~/dotfiles/config', '~/.config')
    ln('~/Common/Private', '~/dotfiles/private')
    ln('~/dotfiles/private/ssh/authorized_keys', '~/.ssh/authorized_keys')
#    ln('~/.config/tmux/tmux.conf', '~/.tmux.conf', if_app='tmux')
#    ln('~/.config/pdb/pdbrc.py', '~/.pdbrc.py', if_app='python')
#    ln('~/.config/hyper/hyper.js', '~/.hyper.js', if_app='hyper')
    ln('~/dotfiles/special/zsh/zshenv', '~/.zshenv')
    ln('~/.config/termux', '~/.termux')
    ln('~/storage/shared/Sync/Common', '~/Common')
    ln('~/dotfiles/special/cygwin/profile', '~/.profile')
    ln('~/dotfiles/special/cygwin/minttyrc', '~/.minttyrc')
    ln('~/.config/git/config-windows', '~/.gitconfig')
    ln('~/.config/hg/hgrc', '~/.hgrc')
    ln('~/.config/omnisharp', '~/.omnisharp')
    ln('~/dotfiles/private/openvpn/config', '~/OpenVPN/config')
    ln('~/Common/_Settings/gimp-2.8',                  '.gimp-2.8')
    ln('~/Common/_Settings/Ssh',                       '.ssh')
    ln('~/Common/_Settings/minttyrc.txt',              '.minttyrc')
    ln('~/Common/Visual Studio 2017',                  'Documents/Visual Studio 2017')
    ln('~/Common/WindowsPowerShell',                   'Documents/WindowsPowerShell')

    if platform.WINDOWS:
        APPDATA = os.getenv('APPDATA')
        ln('~/dotfiles/special/vscode/User', f'{APPDATA}/Code/User')
        ln('~/Games/Factorio', f'{APPDATA}/Factorio')
        ln('~/Programs/Everything', f'{APPDATA}/Everything')

    ln(f'{PROJ}/unity-meta', '~/unity-meta')

if __name__ == "__main__":
    pytest.main(__file__)
