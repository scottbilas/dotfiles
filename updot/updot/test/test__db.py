import json
import pytest
from updot import _db

# note that all modules we want to (directly or indirectly) use the fake filesystem need to be
# imported before creating the fs fixture

# pylint: disable=protected-access
# ^^ TODO: would be nice to have a rule like "test__xyz is ok to access privates in _xyz"

# pylint: disable=redefined-outer-name
# ^^ TODO: may need a pylint plugin to bless reusing fixture names as params (a pytest design
#          feature) to avoid disabling this warning entirely

@pytest.fixture
def db(fs): # pylint: disable=unused-argument
    with _db._Db() as the_db:
        yield the_db

def test__new_db__is_created_with_version_1(db):
    assert db.version == 1

@pytest.mark.usefixtures('fs')
def test__new_db__is_saved_with_version_2():
    with _db._Db() as the_db: # pylint: disable=protected-access
        db_path = the_db.path

    with open(db_path) as file:
        db_json = json.load(file)

    assert db_json['_default']['1']['version'] == 2

    # TODO:
    # move global singleton stuff into a simple accessor (continue to use atexit)
    # unit test the db class directly in this file, probably with a fixture that inherits 'fs' and also does the `with` thing on the db class
    # make a fixture (that inherits 'fs') that mocks the singleton accessor, and use this from test_ln etc.
    # the idea is that the singleton accessor is never called in any test code, because we're always either
    #  mocking it to be reusable, or we're using the class directly.

if __name__ == "__main__":
    pytest.main(__file__)
