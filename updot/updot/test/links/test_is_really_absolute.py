import pytest

from updot import links, platform

# pylint: disable=protected-access


def test__relative_paths__return_false():
    """Relative paths should always return false"""

    assert not links._is_really_absolute('./path/to/thing')
    assert not links._is_really_absolute('../path/to/thing')
    assert not links._is_really_absolute('path/to/thing')


if platform.WINDOWS:
    def test__windows_rooted_paths_on_windows__return_true():
        """Windows-specific rooted paths always return true"""

        assert links._is_really_absolute('c:/abs/path.txt')
        assert links._is_really_absolute('//unc/server/path')

    def test__posix_rooted_paths_on_windows__return_false():
        """Posix-style rooted paths should always return false on Windows"""

        assert not links._is_really_absolute('/path/to/thing')
        assert not links._is_really_absolute(R'\path\to\thing')


if platform.POSIX:
    def test__posix_rooted_paths_on_posix__return_true():
        """Posix-style rooted paths should always return true on posix"""

        assert links._is_really_absolute('/path/to/thing')


if __name__ == "__main__":
    pytest.main(__file__)
