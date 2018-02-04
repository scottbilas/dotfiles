import os
from contextlib import suppress

from updot import exceptions

WINDOWS = os.name == 'nt'
POSIX = os.name == 'posix'
WSL = False
CYGWIN = False
TERMUX = False

if WINDOWS == POSIX:
    raise exceptions.UnexpectedError('Platform detection hit unexpected case')

with suppress(Exception):
    VERSION = open('/proc/version', 'r').read().lower()
    WSL = VERSION.find('microsoft') >= 0
    CYGWIN = VERSION.find('cygwin') >= 0 # or sys.platform=='cygwin'

with suppress(Exception):
    TERMUX = os.environ['PREFIX'].find('com.termux') >= 0
