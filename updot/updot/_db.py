import atexit
import logging
import os
import sys

import tinydb
from tinydb.operations import increment
from tinydb.queries import where
import xdg


SCHEMA = 1 # current db schema version


class _Db:  # pylint: disable=too-few-public-methods
    def __init__(self, path=None):
        if not path:
            path = os.path.join(xdg.XDG_DATA_HOME, 'updot', 'db.json')

        self.path = path        # location of db file
        self.db = None          # the tinydb instance at `path`
        self.schema = 0         # use to guide back- and fwd-compat (if any, or at minimum, use to decide to repave)
        self.serial = 0         # increments each time db is closed; use to garbage collect unreferenced links etc.

    def __enter__(self):
        logging.debug('Using %s', self.path)
        self.db = tinydb.TinyDB(self.path, create_dirs=True)

        self.schema = self.get_or_create_global('schema', SCHEMA)
        self.serial = self.get_or_create_global('serial', 1)

        return self

    def __exit__(self, *args):
        logging.debug('Closing %s', self.path)
        self.db.update(increment('serial'), where('serial') != None)

    def get_or_create_global(self, name, default):
        field = self.db.get(where(name) != None)
        if not field:
            field = {name: default}
            self.db.insert(field)
        return field[name]


_this = sys.modules[__name__]
_this.shared_db = None


def get_shared_db():
    if not _this.shared_db:
        _this.shared_db = _Db()
        _this.shared_db.__enter__()
        atexit.register(_this.shared_db.__exit__)

    return _this.shared_db
