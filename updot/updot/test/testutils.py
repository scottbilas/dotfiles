import os, types
import pytest

from updot import _db, links

# pylint: disable=protected-access

HOME = os.path.expanduser('~').replace('\\', '/')


# only updot main api funcs will automatically do tilde-expansion, so manually expand for everything else
def expand(path):
    exp = HOME + path[1:] if path[0] == '~' else path
    return types.SimpleNamespace(exp=exp, orig=path)

# this fixture provides a local links db and overrides any attempt to get at the global.
# each links db gets its own fake file system too. this should be used as a fixture in any
# test that calls `ln`.
@pytest.fixture
def links_db(monkeypatch, fs):  # pylint: disable=unused-argument
    with _db._Db() as the_db:
        monkeypatch.setattr(_db, 'get_shared_db', lambda: the_db)
        yield links._LinksDb(the_db)
