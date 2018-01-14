import logging
import os
import sys

import tinydb
import xdg

_this = sys.modules[__name__]

CACHE_DIR = os.path.join(xdg.XDG_CACHE_HOME, 'updot')
os.makedirs(CACHE_DIR, exist_ok=True)

DB_FILE = os.path.join(CACHE_DIR, 'db.json')
logging.debug('Using %s', DB_FILE)
_this.db = tinydb.TinyDB(DB_FILE)
