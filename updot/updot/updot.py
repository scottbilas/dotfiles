import logging, os
import exceptions


def normalize_path(path):
    if not os.path.isabs(path):
        raise exceptions.PathInvalidError(path, 'Paths must be absolute (avoid potential for errors from unclear cwd)')
    if '\\' in path:
        raise exceptions.PathInvalidError(path, 'Paths must contain forward slashes only (simplify xplat issues)')

    # replace macros
    # TODO: expand $() style macros with env vars, throwing on not exist

    # ~ replacement and general cleanup
    path = os.path.expanduser(path)
    path = os.path.normpath(path)

    # python path funcs will use backslash, so swap it back
    path = path.replace('\\', '/')

    return path


def ln(link, target):
    link_user, link = link, normalize_path(link)
    target_user, target = target, normalize_path(target) # TODO: catch env var not exist and silent ignore

    # a missing target file is ok; common due to plat and install differences
    if not os.path.exists(target):
        logging.debug('Symlink target %s does not exist; skipping', target_user)
        return None

    if os.path.exists(link):
        pass
        # TODO: test that it points at existing, return if true
        # TODO: if link is already tracked, then delete old and make new

    linkparent = os.path.split(link)
    os.makedirs(linkparent, exist_ok=True)

    # TODO: make dirs up to link parent
    # TODO: error if either is not absolute
    # update state file as we go
    # TODO: error if case doesn't match (for plat compat) -- or -- optionally auto-correct it..?
#    os.symlink(
