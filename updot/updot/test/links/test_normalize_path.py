import os
from pytest import raises
from updot import exceptions, links

# pylint: disable=protected-access


def test__path_not_absolute__throws():
    """Only supporting absolute link paths to avoid script bugs from ambiguity"""

    with raises(exceptions.PathInvalidError):
        links._normalize_path('relative')
    with raises(exceptions.PathInvalidError):
        links._normalize_path('../relative')
    with raises(exceptions.PathInvalidError):
        links._normalize_path('./relative')
    with raises(exceptions.PathInvalidError):
        links._normalize_path('relative/path')


def test__path_with_backslash__throws():
    """Avoid xplat bugs by requiring forward slashes in client code"""

    with raises(exceptions.PathInvalidError):
        links._normalize_path(R'\path')
    with raises(exceptions.PathInvalidError):
        links._normalize_path(R'\path\to\thing')


def test__path_with_redundancy__is_collapsed():
    """Ensure unnecessary `./` and `path/../path` and `//` etc. are collapsed"""

    assert links._normalize_path('/blah/.') == '/blah'
    assert links._normalize_path('/blah/../blah') == '/blah'
    assert links._normalize_path('/blah/./.././blah') == '/blah'
    assert links._normalize_path('/blah//foo') == '/blah/foo'


def test__path_with_tilde__is_expanded_to_home():
    """Ensure only leading ~ is expanded to user home, and with forward slashes"""

    home = os.path.expanduser('~').replace('\\', '/')
    users = os.path.split(home)[0].replace('\\', '/')

    assert links._normalize_path('~') == home
    assert links._normalize_path('~/path/to/thing.txt') == f'{home}/path/to/thing.txt'
    assert links._normalize_path('/path/to/~/thing.txt') == f'/path/to/~/thing.txt'
    assert links._normalize_path('~foo/path') == f'{users}/foo/path'
