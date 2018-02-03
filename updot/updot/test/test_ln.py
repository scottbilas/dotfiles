import os
import types

import pytest
from pytest import raises

from updot import _db, exceptions, links
from updot.links import LinkResult

# pylint: disable=redefined-outer-name, protected-access

HOME = os.path.expanduser('~').replace('\\', '/')


@pytest.fixture
def links_db(monkeypatch, fs):  # pylint: disable=unused-argument
    with _db._Db() as the_db:
        monkeypatch.setattr(_db, 'get_shared_db', lambda: the_db)
        yield links._LinksDb(the_db)


# only updot main api funcs will automatically do tilde-expansion, so manually expand for everything else
def expand(path):
    exp = HOME + path[1:] if path[0] == '~' else path
    return types.SimpleNamespace(exp=exp, orig=path)


# DB TESTS


def test__add_dup_to_db__throws(links_db):
    """Adding twice to the links db isn't allowed"""

    links_db.add('foo', 'bar')

    with raises(exceptions.DbError, match='Unexpected existing link'):
        links_db.add('foo', 'bar2')

    assert links_db.find('foo')['target'] == 'bar', 'second call should not overwrite existing target'


def test__add_out_of_bounds_last_to_db__throws(links_db):
    """Ensure we check bounds on `last` entries in db"""

    # should not throw
    links_db.db.serial = 5
    links_db.add('foo1', 'bar1', 4)
    links_db.add('foo2', 'bar2', 5)

    with raises(exceptions.DbError, match='out of bounds'):
        links_db.add('foo3', 'bar3', -1)
    with raises(exceptions.DbError, match='out of bounds'):
        links_db.add('foo4', 'bar4', 0)
    with raises(exceptions.DbError, match='out of bounds'):
        links_db.add('foo5', 'bar5', 6)

    assert links_db.find('foo3') is None, 'exception should have aborted add'
    assert links_db.find('foo4') is None, 'exception should have aborted add'
    assert links_db.find('foo5') is None, 'exception should have aborted add'


def test__find_out_of_bounds_last_to_db__throws(links_db):
    """Ensure we check bounds on found entries in db against unexpected integrity failure"""

    links_db.db.serial = 5
    links_db.add('foo', 'bar', 5)
    links_db.db.serial = 4

    with raises(exceptions.DbError, match='out of bounds'):
        links_db.find('foo')


# LN TESTS


@pytest.mark.usefixtures('fs')
def test__target_not_exist__ignores(caplog, links_db):
    """Ignore symlinks referring to nonexistent target paths (will be very common across OS's)"""

    link_path = '~/link'

    #|
    result = links.ln(link_path, '~/no-file.txt')
    #|

    assert 'does not exist; skipping' in caplog.text
    assert result == LinkResult.NO_TARGET

    assert links_db.find(link_path) is None
    assert not os.path.exists(f'{HOME}/link')


def test__tracked_link_exists_with_correct_target__ignores(caplog, fs, links_db):
    """Creating an existing symlink should do nothing"""

    file_path, link_path, target = expand('~/file.txt'), expand('~/link'), 'file.txt'
    fs.create_file(file_path.exp, contents='abc')
    fs.create_symlink(link_path.exp, target)
    links_db.db.serial = 5
    links_db.add(link_path.exp, target, 2)

    #|
    result = links.ln(link_path.orig, file_path.orig)
    #|

    assert 'Skipping managed symlink' in caplog.text
    assert result == LinkResult.LINK_OK

    entry = links_db.find(link_path.exp)
    assert entry['link'] == link_path.exp
    assert entry['target'] == target
    assert entry['last'] == 5, '`last` should match db serial now that it has been seen'


def test__untracked_link_exists_with_correct_target__tracks_and_ignores(caplog, fs, links_db):
    """Should take over an already-correct symlink"""

    file_path, link_path, target = expand('~/file.txt'), expand('~/link'), 'file.txt'
    fs.create_file(file_path.exp, contents='abc')
    fs.create_symlink(link_path.exp, target)
    links_db.db.serial = 5

    #|
    result = links.ln(link_path.orig, file_path.orig)
    #|

    assert 'Taking ownership of existing symlink' in caplog.text
    assert result == LinkResult.LINK_OK

    entry = links_db.find(link_path.exp)
    assert entry['link'] == link_path.exp
    assert entry['target'] == target
    assert entry['last'] == 5, 'Entry should have been created with `last` matching db serial'


# TODO: def test__tracked_link_exists_with_different_target__updates():
#    """A symlink we were tracking has changed in spec, so update the symlink"""
#    note: be sure to test addition to state db

# TODO: def test__untracked_link_exists_with_different_target__throws():
#    """Symlink already exists and is pointing somewhere unexpected"""


def test__link_not_exist_and_target_exists__shortens_creates_and_tracks(caplog, fs, links_db):
    """Basic behavior of creating new symlinks"""

    file_contents = 'abc'
    file_path = expand('~/path/to/actual/file.txt')
    link_path = expand('~/path/to/the/.link')
    target = '../actual/file.txt'

    fs.create_file(file_path.exp, contents=file_contents)
    links_db.db.serial = 5

    #|
    result = links.ln(link_path.orig, file_path.orig)
    #|

    assert 'Creating symlink' in caplog.text
    assert result == LinkResult.LINK_OK

    assert os.readlink(link_path.exp).replace('\\', '/') == target, 'link is shortened and not absolute'
    assert fs.resolve(link_path.exp).path.replace('\\', '/') == file_path.exp, 'link resolves correctly'
    assert open(link_path.exp, 'r').read() == file_contents, 'link target matches expected'

    entry = links_db.find(link_path.exp)
    assert entry['link'] == link_path.exp
    assert entry['target'] == target
    assert entry['last'] == 5, 'Entry should have been created with `last` matching db serial'


# TODO: def test__link_parent_not_exist__auto_creates():
#    """Auto-create any parent folders required to create the link"""

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
