import os

if os.name == 'nt':

    # `isabs('/path/to/thing')` returns true on windows, which I think is wrong, so use `splitdrive` instead
    def _fixed_nt_isabs(path):
        return os.path.splitdrive(path)[0] != ''

    # maintainers apparently don't care about https://bugs.python.org/issue9949, so here is @ncdave4life's patched version
    def _fixed_nt_realpath(path):
        """Return the absolute version of a path with symlinks resolved."""

        from nt import _getfinalpathname
        from ntpath import normpath

        if path: # Empty path must return current working directory.
            try:
                path = _getfinalpathname(path)
                if str(path[:4]) == '\\\\?\\':
                    path = path[4:]  # remove the \\?\
            except WindowsError:
                pass # Bad path - return unchanged.
        elif isinstance(path, bytes):
            path = os.getcwdb()
        else:
            path = os.getcwd()
        return normpath(path)

    # install overrides
    os.path.isabs = _fixed_nt_isabs
    os.path.realpath = _fixed_nt_realpath
