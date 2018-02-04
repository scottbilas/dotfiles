import contextlib
import os
import types


HOME = os.path.expanduser('~').replace('\\', '/')


# only updot main api funcs will automatically do tilde-expansion, so manually expand for everything else
def expand(path):
    exp = HOME + path[1:] if path[0] == '~' else path
    return types.SimpleNamespace(exp=exp, orig=path)
