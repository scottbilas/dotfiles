import os

# maintainers apparently don't care about https://bugs.python.org/issue9949, so here is @ncdave4life's patched version
if os.name == 'nt':
    def _fixed_nt_realpath(path):
        from nt import _getfinalpathname
        from ntpath import normpath

        """Return the absolute version of a path with symlinks resolved."""

        if path: # Empty path must return current working directory.
            try:
                path = _getfinalpathname(path)
                if str(path[:4]) == '\\\\?\\':
                    # For some unknown strange reason, Windows puts \\?\ on the front, before the drive letter
                    path = path[4:]  # remove the \\?\
            except WindowsError:
                pass # Bad path - return unchanged.
        elif isinstance(path, bytes):
            path = os.getcwdb()
        else:
            path = os.getcwd()
        return normpath(path)

    os.path.realpath = _fixed_nt_realpath
