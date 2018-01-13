import logging, os
import updot


def _normalize_path(path):

    if '\\' in path:
        raise updot.exceptions.PathInvalidError(path, 'Paths must contain forward slashes only (simplify xplat issues)')

    path = os.path.expanduser(path) # expand tilde before we check absolute

    if not os.path.isabs(path):
        raise updot.exceptions.PathInvalidError(path, 'Paths must be home-based or absolute (avoid potential for errors from unclear cwd)')

    # replace macros
    # TODO: expand $() style macros with env vars, throwing on not exist

    # ~ replacement and general cleanup
    path = os.path.normpath(path)

    # python path funcs will use backslash, so swap it back
    path = path.replace('\\', '/')

    # TODO: for each level of path that exists, validate that the actual case matches what we have

    return path


def ln(link, target):
    link_user, link = link, _normalize_path(link)
    target_user, target = target, _normalize_path(target)  # TODO: catch env var not exist and silent ignore

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
