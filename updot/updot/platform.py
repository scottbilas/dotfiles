import os
from contextlib import suppress

WINDOWS = os.name == 'nt'
POSIX = not WINDOWS
WSL = False
CYGWIN = False
TERMUX = False

with suppress(Exception):
    VERSION = open('/proc/version', 'r').read().lower()
    WSL = VERSION.find('microsoft') >= 0
    CYGWIN = VERSION.find('cygwin') >= 0

with suppress(Exception):
    TERMUX = os.environ['PREFIX'].find('com.termux') >= 0
