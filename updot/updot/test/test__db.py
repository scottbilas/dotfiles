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
def db(fs):  # pylint: disable=unused-argument
    with _db._Db() as the_db:
        yield the_db


@pytest.mark.usefixtures('fs')
def test__db_open_close__increments_version():

    db_path = '~/db.json'

    def version_from_json():
        with open(db_path) as file:
            db_json = json.load(file)
        return db_json['_default']['1']['version']

    with _db._Db(db_path) as the_db:
        assert the_db.version == 1
    assert version_from_json() == 2

    with _db._Db(db_path):
        pass
    assert version_from_json() == 3

    with _db._Db(db_path):
        pass
    assert version_from_json() == 4


if __name__ == "__main__":
    pytest.main(__file__)
