import logging
import os
import sys

import tinydb
from tinydb.operations import increment
import xdg

_this = sys.modules[__name__]
_this.initialized = False

def _init():
    assert not _this.initialized
    _this.initialized = True

    # create/open db

    cache_dir = os.path.join(xdg.XDG_DATA_HOME, 'updot')
    os.makedirs(cache_dir, exist_ok=True)

    db_file = os.path.join(cache_dir, 'db.json')
    logging.debug('Using %s', db_file)
    _this.db = tinydb.TinyDB(db_file)

    # get db version, which can be used to remove expired elements that we maintain

    glob = _this.db.table('global')
    q = tinydb.Query()

    ver_field = glob.get(q.version != None)
    if ver_field:
        _this.version = ver_field['version']
    else:
        _this.version = 0
        glob.insert({'version': 1})

    # tick version on shutdown

    import atexit
    atexit.register(lambda: glob.update(increment('version'), q.version != None))

_init()
