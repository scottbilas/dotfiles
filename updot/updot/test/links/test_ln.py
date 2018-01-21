import os

import pytest

from updot import links


# TODO:
# make a fixture (that inherits 'fs') that mocks the singleton accessor


# TODO: def test__tracked_link_exists_with_correct_target__ignores():
#    """Rebuilding an existing symlink should do nothing"""

# TODO: def test__untracked_link_exists_with_correct_target__tracks_and_ignores():
#    """Should take over an already-correct symlink"""
#    note: be sure to test addition to state db

# TODO: def test__tracked_link_exists_with_different_target__updates():
#    """A symlink we were tracking has changed in spec, so update the symlink"""
#    note: be sure to test addition to state db

# TODO: def test__untracked_link_exists_with_different_target__throws():
#    """Symlink already exists and is pointing somewhere unexpected"""

def test__link_not_exist_and_target_exists__shortens_creates_and_tracks(fs):
    """Basic behavior of creating new symlinks"""

    fs.create_file('~/path/to/actual/file.txt', contents='abc')

    links.ln('~/path/to/link', '~/path/to/actual/file.txt')

    # ensure link is shortened and not absolute
    assert os.readlink('~/path/to/link').replace('\\', '/') == '../actual/file.txt'
    assert open('~/path/to/link', 'r').read() == 'abc'

    # TODO: test addition to state db


# TODO: def test__link_parent_not_exist__auto_creates():
#    """Auto-create any parent folders required to create the link"""

def test__target_not_exist__ignores(fs):  # pylint: disable=unused-argument
    """Ignore symlinks referring to nonexistent target paths (will be very common across OS's)"""

    links.ln('~/link', '/var/data/no-file.txt')
    assert not os.path.exists('~/link')


# TODO: def test__dup_target_and_link__throws(fs):
#    """Catch accidental duplication of symlinks"""


# TODO: def test__unspecified_symlinks_found_in_any_link_parent__warns():
#    """Detect when user has added symlinks manually and forgotten to update spec"""
    # FUTURE: offer to add to spec
    # FUTURE: offer to ignore future warnings about this (store in local state file)


# TODO: def test__windows_symlink_creation_failed_due_to_no_admin__fatals_with_help():
#    """Let user know they should enable Developer Mode or run as admin"""
    # should be a permissions problem that leads to this


if __name__ == "__main__":
    pytest.main(__file__)
