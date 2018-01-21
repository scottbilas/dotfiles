import atexit
import logging
import os
import sys

import tinydb
from tinydb.operations import increment
from tinydb.queries import where
import xdg


class _Db:
    def __init__(self, path=None):
        if not path:
            path = os.path.join(xdg.XDG_DATA_HOME, 'updot', 'db.json')

        self.path = path        # location of db file
        self.db = None          # the tinydb instance at `path`
        self.version = 0        # increments each time db is closed; use to garbage collect unreferenced links etc.

    def __enter__(self):
        logging.debug('Using %s', self.path)
        self.db = tinydb.TinyDB(self.path, create_dirs=True)

        ver_field = self.db.get(where('version') != None)
        if ver_field:
            self.version = ver_field['version']
        else:
            self.version = 1
            self.db.insert({'version': 1})

        return self

    def __exit__(self, *args):
        logging.debug('Closing %s', self.path)
        self.db.update(increment('version'), where('version') != None)


_this = sys.modules[__name__]
_this.shared_db = None

def get_shared_db():
    if not _this.shared_db:
        _this.shared_db = _Db()
        _this.shared_db.__enter__()
        atexit.register(_this.shared_db.__exit__)
