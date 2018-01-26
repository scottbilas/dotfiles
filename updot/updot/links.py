import logging
import os
from enum import Enum, auto

from updot import exceptions, platform


def _is_really_absolute(path):
    # `isabs('/path/to/thing')` returns true on windows for some reason, so use `splitdrive` instead
    if platform.WINDOWS:
        return os.path.splitdrive(path)[0] != ''

    return os.path.isabs(path)


def _normalize_path(path):
    path_orig = path

    # check slashes before we expand tilde
    if '\\' in path:
        raise exceptions.PathInvalidError(path_orig, 'Paths must contain forward slashes only (simplify xplat issues)')

    # expand macros before we check absolute
    path = os.path.expanduser(path)
    if '$' in path:
        # TODO: expand $ style macros with env vars, throwing MacroNotFoundError if not exist
        raise exceptions.PathInvalidError(path_orig, '"$ macro" expansion not currently supported')

    # general cleanup
    path = os.path.normpath(path)

    # this is mostly a stylistic choice at this point, but i also think it will help avoid
    # accidental cross plat problems.
    if not _is_really_absolute(path):
        raise exceptions.PathInvalidError(path_orig, 'All paths (after expansion) must be absolute')

    # python path funcs will use backslash, so swap it back
    path = path.replace('\\', '/')

    # TODO: if windows-style path (\\unc\path or C:\blah), then for each level of path that exists,
    # validate that the case of the path on disk matches exactly what `path` has. point of this is
    # to catch potential failures going from windows to linux (going the other way would be fine).
    # though..consider whether to warn about multiple symlinks in the same folder with same name but
    # different casing.
    # (see answers in https://stackoverflow.com/a/35229734/14582 for ideas)

    return path


class LinkResult(Enum):
    SKIPPED = auto()    # didn't do anything
    CREATED = auto()    # created a new link
    ADJUSTED = auto()   # recreated an existing managed link to point to a new target


# TODO: optional 'exe' param to test if in path and skip making link if not (for example dont clutter with ~/.tmux.conf if no tmux installed)
def ln(link, target):
    link = _normalize_path(link)
    target_orig, target = target, _normalize_path(target)  # TODO: catch env var not exist and silent ignore

    # a missing target file is ok; common due to plat and install differences
    if not os.path.exists(target):
        logging.debug('Symlink target %s does not exist; skipping', target_orig)
        return LinkResult.SKIPPED

    # TODO: Make the link target relative.  This usually makes the link
    # shorter in `ls` output.
    # ... but only if it's worth it. may end up with ../../.../../.././..//. where a simple root base would be shorter. so test results for length before changing.
    # on the other hand, if we have a lot of these in one folder, they may become inconsistent if their targets are slightly different lengths from each other..
    # anyway, it's `link_target = os.path.relpath(file_pathname, link_dir)`

    # link possibilities:
    #
    #  1. doesn't exist (just create it and take ownership)
    #  2. exists, but isn't a link (throw) [TODO: if file, offer to user to show first 10 lines and overwrite with link, take ownership; maybe same if empty dir]
    #  3. is a link, but points at something else (move if managed, throw otherwise) [TODO: offer to user to take ownership]
    #  4. already points at target (move if managed, take ownership with warning otherwise)
    #
    # for cases 3 and 4, behavior will change depending on whether the symlink is already managed

    managed = True

    if os.path.exists(link):
        target_existing = os.readlink(link)  # will throw if not a link

        if target_existing == target:
            if not managed:
                pass
        elif managed:
            pass
        else:
            pass

    linkparent = os.path.split(link)[0]
    if not os.path.exists(linkparent):
        logging.debug('Creating symlink parent folder %s', linkparent)
        os.makedirs(linkparent)

    os.symlink(target, link)

    #db.remove(query.link == link)
#$$$    db.insert({'link': link, 'version': _db.})

    # TODO: at end of program...
    # 1. find all unused but managed links and delete them
    # 2. warn about all unmanaged links found in all parent folders of links

    return LinkResult.CREATED