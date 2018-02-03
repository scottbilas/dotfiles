import os

import pytest

from updot import platform

# pylint: disable=protected-access


def test__relative_paths__return_false():
    """Relative paths should always return false"""

    assert not os.path.isabs('./path/to/thing')
    assert not os.path.isabs('../path/to/thing')
    assert not os.path.isabs('path/to/thing')


if platform.WINDOWS:
    def test__windows_rooted_paths_on_windows__return_true():
        """Windows-specific rooted paths always return true"""

        assert os.path.isabs('c:/abs/path.txt')
        assert os.path.isabs('//unc/server/path')

    def test__posix_rooted_paths_on_windows__return_false():
        """Posix-style rooted paths should always return false on Windows"""

        assert not os.path.isabs('/path/to/thing')
        assert not os.path.isabs(R'\path\to\thing')


if platform.POSIX:
    def test__posix_rooted_paths_on_posix__return_true():
        """Posix-style rooted paths should always return true on posix"""

        assert os.path.isabs('/path/to/thing')


if __name__ == "__main__":
    pytest.main(__file__)
