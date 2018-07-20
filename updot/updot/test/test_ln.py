import logging, os

import pytest
from pytest import raises

from testutils import HOME, expand
from updot import _db, exceptions, links
from updot.links import LinkResult

# pylint: disable=redefined-outer-name, protected-access

# this fixture provides a local links db and overrides any attempt to get at the global.
# each links db gets its own fake file system too. this should be used as a fixture in any
# test that calls `ln`.
@pytest.fixture
def links_db(monkeypatch, fs):  # pylint: disable=unused-argument
    with _db._Db() as the_db:
        monkeypatch.setattr(_db, 'get_shared_db', lambda: the_db)
        yield links._LinksDb(the_db)


# DB TESTS


def test__add_dup_to_db__throws(links_db):
    """Adding twice to the links db isn't allowed"""

    links_db.add('foo', 'bar')

    with raises(exceptions.DbError, match='Unexpected existing link'):
        links_db.add('foo', 'bar2')

    assert links_db.find('foo')['target'] == 'bar', 'second call should not overwrite existing target'


def test__add_out_of_bounds_last_to_db__throws(links_db):
    """Ensure we check bounds on `last` entries in db"""

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

    db_serial = 5

    links_db.db.serial = db_serial
    links_db.add('foo', 'bar', db_serial)
    links_db.db.serial = db_serial - 1

    with raises(exceptions.DbError, match='out of bounds'):
        links_db.find('foo')


# LN TESTS


@pytest.mark.usefixtures('fs')
def test__target_not_exist__ignores(caplog, links_db):
    """Ignore symlinks referring to nonexistent target paths (will be very common across OS's)"""

    caplog.set_level(logging.DEBUG)

    link_path = '~/link'

    #|
    result = links.ln(link_path, '~/no-file.txt')
    entry = links_db.find(link_path)
    #|

    assert 'does not exist; skipping' in caplog.text
    assert result == LinkResult.NO_TARGET
    assert entry is None
    assert not os.path.exists(f'{HOME}/link')


def test__tracked_link_exists_with_correct_target__ignores(caplog, fs, links_db):
    """Creating an existing symlink should do nothing"""

    caplog.set_level(logging.DEBUG)

    file_path, link_path, target = expand('~/file.txt'), expand('~/link'), 'file.txt'
    db_serial = 5

    fs.create_file(file_path.exp)
    fs.create_symlink(link_path.exp, target)
    links_db.db.serial = db_serial
    links_db.add(link_path.exp, target, db_serial - 1)

    #|
    result = links.ln(link_path.orig, file_path.orig)
    entry = links_db.find(link_path.exp)
    #|

    assert 'Skipping managed symlink' in caplog.text
    assert result == LinkResult.LINK_OK
    assert entry == {'link': link_path.exp, 'target': target, 'last': db_serial}


def test__untracked_link_exists_with_correct_target__tracks_and_ignores(caplog, fs, links_db):
    """Should take over an already-correct symlink"""

    caplog.set_level(logging.DEBUG)

    file_path, link_path, target = expand('~/file.txt'), expand('~/link'), 'file.txt'
    db_serial = 20

    fs.create_file(file_path.exp)
    fs.create_symlink(link_path.exp, target)
    links_db.db.serial = db_serial

    #|
    result = links.ln(link_path.orig, file_path.orig)
    entry = links_db.find(link_path.exp)
    #|

    assert 'Taking ownership of existing symlink' in caplog.text
    assert result == LinkResult.LINK_OK
    assert entry == {'link': link_path.exp, 'target': target, 'last': db_serial}


def test__tracked_link_exists_with_different_target__updates(caplog, fs, links_db):
    """A symlink we were tracking has changed in spec, so update the symlink"""

    caplog.set_level(logging.DEBUG)

    file_moved_path, link_path = expand('~/moved.txt'), expand('~/link')
    target_existing, target_moved = 'existing.txt', 'moved.txt'
    db_serial = 30

    # symlink and db entry point to old location
    fs.create_symlink(link_path.exp, target_existing)
    links_db.db.serial = db_serial
    links_db.add(link_path.exp, target_existing, db_serial - 1)

    # but the file has been 'moved' already to its new location
    fs.create_file(file_moved_path.exp)

    #|
    result = links.ln(link_path.orig, file_moved_path.orig)
    entry = links_db.find(link_path.exp)
    #|

    assert 'Moving managed symlink' in caplog.text
    assert result == LinkResult.LINK_OK
    assert entry['target'] == target_moved


def test__untracked_link_exists_with_different_target__returns_mismatch(caplog, fs, links_db):
    """Symlink already exists, but is not managed and is pointing somewhere unexpected"""

    caplog.set_level(logging.DEBUG)

    file_path, link_path = expand('~/file.txt'), expand('~/link')
    fs.create_file(file_path.exp)
    fs.create_symlink(link_path.exp, 'otherfile.txt')

    #|
    result = links.ln(link_path.orig, file_path.orig)
    #|

    assert 'Unmanaged symlink found' in caplog.text
    assert result == LinkResult.LINK_MISMATCH


def test__link_not_exist_and_target_exists__shortens_creates_and_tracks(caplog, fs, links_db):
    """Basic behavior of creating new symlinks"""

    caplog.set_level(logging.DEBUG)

    file_contents = 'abc'
    file_path = expand('~/path/to/actual/file.txt')
    link_path = expand('~/path/to/the/.link')
    target = '../actual/file.txt'
    db_serial = 12

    fs.create_file(file_path.exp, contents=file_contents)
    links_db.db.serial = db_serial

    #|
    result = links.ln(link_path.orig, file_path.orig)
    entry = links_db.find(link_path.exp)
    #|

    assert 'Creating symlink' in caplog.text
    assert 'Creating parent folder' in caplog.text
    assert result == LinkResult.LINK_OK
    assert entry == {'link': link_path.exp, 'target': target, 'last': db_serial}

    assert os.readlink(link_path.exp).replace('\\', '/') == target, 'link is shortened and not absolute'
    assert fs.resolve(link_path.exp).path.replace('\\', '/') == file_path.exp, 'link resolves correctly'
    assert open(link_path.exp, 'r').read() == file_contents, 'link target matches expected'


def test__dup_target_and_link__throws(fs, links_db):  # pylint: disable=unused-argument
    """Catch accidental duplication of symlinks"""

    file_path, file2_path, link_path = expand('~/file.txt'), expand('~/file2.txt'), expand('~/link')

    fs.create_file(file_path.exp)
    fs.create_file(file2_path.exp)

    links.ln(link_path.orig, file_path.orig)
    with raises(exceptions.UpdotError, match='Duplicate creation of symlink'):
        links.ln(link_path.orig, file_path.orig)
    with raises(exceptions.UpdotError, match='Duplicate creation of symlink'):
        links.ln(link_path.orig, file2_path.orig)


def test__symlink_pointing_at_self__throws(fs, links_db):  # pylint: disable=unused-argument
    """Catch accidental creation of self-referential symlinks"""

    file_path = expand('~/foo')
    fs.create_file(file_path.exp)

    # TODO: add parent-dir symlinks to look through before hitting `foo`, to
    # exercise the `realpath` stuff.

    #|
    with raises(exceptions.PathInvalidError, match='Symlink points at itself'):
        links.ln(file_path.orig, file_path.orig)


def test__symlink_pointing_at_cycle__throws(fs, links_db):  # pylint: disable=unused-argument
    """Catch when referencing a symlink cycle"""

    cycle_path, target = expand('~/foo'), 'foo'
    fs.create_symlink(cycle_path.exp, target)

    #|
    with raises(OSError, match='Too many levels of symbolic links'):
        links.ln('~/leaf', cycle_path.orig)


# TODO: def test__unspecified_symlinks_found_in_any_link_parent__warns():
#    """Detect when user has added symlinks manually and forgotten to update spec"""
    # FUTURE: offer to add to spec
    # FUTURE: offer to ignore future warnings about this (store in local state file)


# TODO: def test__windows_symlink_creation_failed_due_to_no_admin__fatals_with_help():
#    """Let user know they should enable Developer Mode or run as admin"""
#
# * detect if windows and have SeCreateSymbolicLinkPrivilege and fatal asking for sudo otherwise
#   see docs on `os.symlink`. obviously we only need to bother with this outside of pytest.


if __name__ == "__main__":
    pytest.main([__file__, '-k', 'test'])
