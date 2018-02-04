import contextlib
import os
import types


HOME = os.path.expanduser('~').replace('\\', '/')


# adapted from https://stackoverflow.com/a/34333710/14582
@contextlib.contextmanager
def modified_environ(*remove, **update):
    """
    Temporarily updates the ``os.environ`` dictionary in-place.

    The ``os.environ`` dictionary is updated in-place so that the modification
    is sure to work in all situations.

    :param remove: Environment variables to remove.
    :param update: Dictionary of environment variables and values to add/update.
    """
    env = os.environ
    update = update or {}
    remove = remove or []

    # List of environment variables being updated or removed.
    stomped = (set(update.keys()) | set(remove)) & set(env.keys())
    # Environment variables and values to restore on exit.
    update_after = {k: env[k] for k in stomped}
    # Environment variables and values to remove on exit.
    remove_after = frozenset(k for k in update if k not in env)

    try:
        env.update(update)
        for item in remove:
            env.pop(item, None)
        yield
    finally:
        env.update(update_after)
        for item in remove_after:
            env.pop(item)


# only updot main api funcs will automatically do tilde-expansion, so manually expand for everything else
def expand(path):
    exp = HOME + path[1:] if path[0] == '~' else path
    return types.SimpleNamespace(exp=exp, orig=path)
