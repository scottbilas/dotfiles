import os

import pytest
from pytest import raises

from updot import exceptions, links, platform

# pylint: disable=protected-access


def test__path_not_absolute__throws():
    """Disallowing relative link paths to avoid potential script bugs from ambiguity"""

    with raises(exceptions.PathInvalidError, match='must be absolute'):
        links._normalize_path('relative')
    with raises(exceptions.PathInvalidError, match='must be absolute'):
        links._normalize_path('../relative')
    with raises(exceptions.PathInvalidError, match='must be absolute'):
        links._normalize_path('./relative')
    with raises(exceptions.PathInvalidError, match='must be absolute'):
        links._normalize_path('relative/path')


def test__path_with_backslash__throws():
    """Avoid xplat bugs by requiring forward slashes in client code"""

    with raises(exceptions.PathInvalidError, match='forward slashes only'):
        links._normalize_path(R'\path')
    with raises(exceptions.PathInvalidError, match='forward slashes only'):
        links._normalize_path(R'\path\to\thing')


def test__path_with_redundancy__is_collapsed():
    """Ensure unnecessary `./` and `path/../path` and `//` etc. are collapsed"""

    root = "C:" if platform.WINDOWS else ""

    assert links._normalize_path(f'{root}/blah/.') == f'{root}/blah'
    assert links._normalize_path(f'{root}/blah/../blah') == f'{root}/blah'
    assert links._normalize_path(f'{root}/blah/./.././blah') == f'{root}/blah'
    assert links._normalize_path(f'{root}/blah//foo') == f'{root}/blah/foo'


def test__path_with_tilde__is_expanded_to_home():
    """Ensure only leading ~ is expanded to user home, and with forward slashes"""

    home = os.path.expanduser('~').replace('\\', '/')
    users = os.path.split(home)[0].replace('\\', '/')

    assert links._normalize_path('~') == home
    assert links._normalize_path('~/path/to/thing.txt') == f'{home}/path/to/thing.txt'
    assert links._normalize_path('~/path/to/~/thing.txt') == f'{home}/path/to/~/thing.txt'


def test__path_with_user_specific_tilde__throws():
    """Ensure that non-xplat-compatible ~foo style paths are not permitted"""

    with raises(exceptions.PathInvalidError, match='Tilde-based paths that select a user'):
        links._normalize_path('~foo/path')


if __name__ == "__main__":
    pytest.main(__file__)
