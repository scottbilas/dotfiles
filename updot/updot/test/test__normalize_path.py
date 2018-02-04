import os

import pytest
from pytest import raises

from testutils import HOME
from updot import exceptions, platform
from updot.links import _normalize_path

# pylint: disable=protected-access


def test__path_not_absolute__throws():
    """Disallowing relative link paths to avoid potential script bugs from ambiguity"""

    with raises(exceptions.PathInvalidError, match='must be absolute'):
        _normalize_path('relative')
    with raises(exceptions.PathInvalidError, match='must be absolute'):
        _normalize_path('../relative')
    with raises(exceptions.PathInvalidError, match='must be absolute'):
        _normalize_path('./relative')
    with raises(exceptions.PathInvalidError, match='must be absolute'):
        _normalize_path('relative/path')


def test__path_with_backslash__throws():
    """Avoid xplat bugs by requiring forward slashes in client code"""

    with raises(exceptions.PathInvalidError, match='forward slashes only'):
        _normalize_path(r'\path')
    with raises(exceptions.PathInvalidError, match='forward slashes only'):
        _normalize_path(r'\path\to\thing')


def test__path_with_redundancy__is_collapsed():
    """Ensure unnecessary `./` and `path/../path` and `//` etc. are collapsed"""

    root = "C:" if platform.WINDOWS else ""

    assert _normalize_path(f'{root}/blah/.') == f'{root}/blah'
    assert _normalize_path(f'{root}/blah/../blah') == f'{root}/blah'
    assert _normalize_path(f'{root}/blah/./.././blah') == f'{root}/blah'
    assert _normalize_path(f'{root}/blah//foo') == f'{root}/blah/foo'


def test__path_with_tilde__is_expanded_to_home():
    """Ensure only leading ~ is expanded to user home, and with forward slashes"""

    home = os.path.expanduser('~').replace('\\', '/')

    assert _normalize_path('~') == home
    assert _normalize_path('~/path/to/thing.txt') == f'{home}/path/to/thing.txt'
    assert _normalize_path('~/path/to/~/thing.txt') == f'{home}/path/to/~/thing.txt'


def test__path_with_user_specific_tilde__throws():
    """Ensure that non-xplat-compatible ~foo style paths are not permitted"""

    with raises(exceptions.PathInvalidError, match='Tilde-based paths that select a user'):
        _normalize_path('~foo/path')


def test__path_with_macros__expands(monkeypatch):
    """Ensure basic macro expansion works"""

    monkeypatch.setenv('ABSOLUTE', f'{HOME}/path/to/something')
    monkeypatch.setenv('INNER', 'something-else')
    monkeypatch.setenv('RELATIVE', 'another/path')

    #|
    result1 = _normalize_path('$ABSOLUTE/and/$INNER/but/$RELATIVE/file.txt')
    result2 = _normalize_path('~/and/$RELATIVE/file.txt')
    result3 = _normalize_path('~/partial$INNER/$RELATIVE.txt~')

    with raises(exceptions.PathInvalidError, match='must be absolute'):
        result2 = _normalize_path("$INNER/file.txt")
    with raises(exceptions.PathInvalidError, match='must be absolute'):
        result2 = _normalize_path("$RELATIVE/~INNER.txt")

    #|
    assert result1 == f'{HOME}/path/to/something/and/something-else/but/another/path/file.txt'
    assert result2 == f'{HOME}/and/another/path/file.txt'
    assert result3 == f'{HOME}/partialsomething-else/another/path.txt~'


def test__path_with_abs_macro_in_middle__throws(monkeypatch):
    """Paths using an absolute path macro in the middle should throw"""

    monkeypatch.setenv('ABSOLUTE', f'{HOME}/path/to/something')

    #|
    with raises(exceptions.MacroExpansionError, match='absolute path.*not used from the start'):
        _normalize_path('/$ABSOLUTE/path')
    with raises(exceptions.MacroExpansionError, match='absolute path.*not used from the start'):
        _normalize_path('f{HOME}/$ABSOLUTE')


def test__path_with_invalid_macros__throws(monkeypatch):
    """Paths using invalid or empty macros should throw"""

    monkeypatch.delenv('MISSING', False)
    monkeypatch.setenv('EMPTY', '')

    #|
    with raises(exceptions.MacroExpansionError, match='Macro.*not found'):
        _normalize_path('$MISSING')
    with raises(exceptions.MacroExpansionError, match='Macro.*not found'):
        _normalize_path(f'{HOME}/path/to/$MISSING/file')
    with raises(exceptions.MacroExpansionError, match='Macro.*not found'):
        _normalize_path('$EMPTY')
    with raises(exceptions.MacroExpansionError, match='Macro.*not found'):
        _normalize_path(f'{HOME}/path/to/$EMPTY/file')


def test__path_with_escaped_dollar_sign__returns_unescaped(monkeypatch):
    """Can use a backslash to escape `$`"""

    monkeypatch.setenv('FOO', 'foo')
    monkeypatch.delenv('MISSING', False) # ensure no match by accident

    #|
    result = _normalize_path(r'~/$FOO/\$FOO/$/path/test$FOO/and\$FOO')
    #|

    assert result == f'{HOME}/foo/$FOO/$/path/testfoo/and$FOO'


if platform.WINDOWS: # this test makes no sense on posix (it will throw that the env var isn't found)
    def test__macro_expansion_with_case_mismatched_env__throws(monkeypatch):

        monkeypatch.setenv('FOO', 'foo')

        #|
        with raises(exceptions.MacroExpansionError, match='does not match case of actual env'):
            _normalize_path('~/$Foo/bar.txt')


if platform.POSIX: # this test is useless on windows (the second `setenv` will replace the first)
    def test__macro_expansion_with_multiple_icase_env_entries__throws(monkeypatch):

        monkeypatch.setenv('Foo', 'baz')
        monkeypatch.setenv('FOO', 'bar')

        #|
        with raises(exceptions.MacroExpansionError, match='has multiple case-insensitive env matches'):
            _normalize_path('~/$Foo/$FOO')



if __name__ == "__main__":
    pytest.main(__file__)
