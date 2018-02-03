import os
import types

import pytest
from pytest import raises

from updot import _db, exceptions, links

# pylint: disable=redefined-outer-name

HOME = os.path.expanduser('~').replace('\\', '/')


def expand(path):
    result = types.SimpleNamespace()
    result.expanded = HOME + path[1:] if path[0] == '~' else path
    result.orig = path
    return result


@pytest.fixture
# pylint: disable=protected-access, unused-argument
def links_db(monkeypatch, fs):
    with _db._Db() as the_db:
        monkeypatch.setattr(_db, 'get_shared_db', lambda: the_db)
        yield links._LinksDb(the_db)


def test__add_dup_to_db__throws(links_db):
    """Adding twice to the links db isn't allowed"""

    links_db.add('foo', 'bar')

    with raises(exceptions.DbError):
        links_db.add('foo', 'bar')


def test__tracked_link_exists_with_correct_target__ignores(links_db, fs):
    """Creating an existing symlink should do nothing"""

    # ARRANGE

    file_path, link_path, target = expand('~/file.txt'), expand('~/link'), 'file.txt'

    fs.create_file(file_path.expanded, contents='abc')
    fs.create_symlink(link_path.expanded, target)
    links_db.add(link_path.expanded, target)

    # ACT

    linked = links.ln(link_path.orig, file_path.orig)

    # ASSERT

    assert linked == links.LinkResult.LINK_OK
    # test db
    # test captured debug output


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

    # ARRANGE

    file_contents = 'abc'
    file_path = expand('~/path/to/actual/file.txt')
    link_path = expand('~/path/to/the/.link')
    target = '../actual/file.txt'

    fs.create_file(file_path.expanded, contents=file_contents)

    # ACT

    # only `ln` supports tilde-expansion, so everything else gets pre-expanded versions
    links.ln(link_path.orig, file_path.orig)

    # ASSERT

    # ensure link is shortened and not absolute
    assert os.readlink(link_path.expanded).replace('\\', '/') == target

    # ensure the symlink resolves correctly
    assert fs.resolve(link_path.expanded).path.replace('\\', '/') == file_path.expanded
    assert open(link_path.expanded, 'r').read() == file_contents

    # TODO: test addition to state db


# TODO: def test__link_parent_not_exist__auto_creates():
#    """Auto-create any parent folders required to create the link"""

def test__target_not_exist__ignores(fs):  # pylint: disable=unused-argument
    """Ignore symlinks referring to nonexistent target paths (will be very common across OS's)"""

    links.ln('~/link', '~/no-file.txt')

    assert not os.path.exists(f'{HOME}/link')


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
