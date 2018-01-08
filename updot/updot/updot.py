import logging, os
from updot import exceptions

def normalize_path(path):
    if not os.path.isabs(path):
        raise exceptions.PathInvalidError(path, 'Paths must be absolute (avoid potential for errors from unclear cwd)')
    if '\\' in path:
        raise exceptions.PathInvalidError(path, 'Paths must contain forward slashes only (simplify xplat issues)')

    # ~ replacement and general cleanup
    path = os.path.expanduser(path)
    path = os.path.normpath(path)

    # python path funcs will use backslash, so swap it back
    path = path.replace('\\', '/')

    # TODO: env vars expansion w auto error handling

def ln(link, target):
    link_user, link = link, normalize_path(link)
    target_user, target = target, normalize_path(target)

    # a missing target file is ok, very common due to plat and install differences, so silently ignore
    if not os.path.exists(target):
        logging.debug('Symlink target %s does not exist; skipping', target_user)
        return None

    if os.path.exists(link):
        ...


    linkparent = os.path.split(link)
    os.makedirs(linkparent, exist_ok = True)

    # TODO: make dirs up to link parent
    # TODO: error if either is not absolute
    # update state file as we go
    # TODO: error if case doesn't match (for plat compat) -- or -- optionally auto-correct it..?
#    os.symlink(
