import logging
import os
from enum import Enum, auto

from tinydb import where

from updot import _db, exceptions, platform


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

    # check user-tilde before expansion (see docs on `os.expanduser` to see how unix differs from win)
    if path[0] == '~' and len(path) > 1 and path[1] != '/':
        raise exceptions.PathInvalidError(path_orig, 'Tilde-based paths that select a user are not xplat-friendly and therefore disallowed')

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


class _LinksDb:
    def __init__(self, db=None):
        self.db = db if db else _db.get_shared_db()
        self.links = self.db.db.table('links')

    def add(self, link, target):
        existing = self.find(link)
        if existing:
            raise exceptions.DbError(f'Unexpected existing link ''{link}''')

        self.links.insert({
            'link': link,
            'target': target,
            'last': self.db.serial})

    def find(self, link):
        return self.links.get(where('link') == link)


# TODO: optional 'exe' param to test if in path and skip making link if not (for example dont clutter with ~/.tmux.conf if no tmux installed)
def ln(link, target):
    link_orig, link = link, _normalize_path(link)
    target_orig, target = target, _normalize_path(target)  # TODO: catch env var not exist and silent ignore

    # a missing target file is ok; common due to plat and install differences
    if not os.path.exists(target):
        logging.debug('Symlink target ''%s'' does not exist; skipping', target_orig)
        return LinkResult.SKIPPED

    # special: if both home-relative, make them relative to each other (shortens `ls`)
    target_final = target
    if link_orig.startswith('~/') and target_orig.startswith('~/'):
        target_final = os.path.relpath(target, os.path.split(link)[0])

    links_db = _LinksDb()
    managed = links_db.find(link)

    # link possibilities:
    #
    #  1. doesn't exist (just create it and take ownership)
    #  2. exists, but isn't a link (throw) [TODO: if file, offer to user to show first 10 lines and overwrite with link, take ownership; maybe same if empty dir or existing file contents match target of link]
    #  3. is a link, but points at something else (move if managed, throw otherwise) [TODO: offer to user to take ownership]
    #  4. already points at target (move if managed, take ownership with warning otherwise)
    #
    # for cases 3 and 4, behavior will change depending on whether the symlink is already managed

    # TODO: fill out this if-tree
    if os.path.exists(link):
        target_existing = os.readlink(link)  # will throw if not a link

        if target_existing == target_final:
            if managed:
                # skip
                # update 'last'
                pass
            else:
                # take ownership
                pass
        elif managed:
            pass
        else:
            pass

    link_parent = os.path.split(link)[0]
    if not os.path.exists(link_parent):
        logging.debug('Creating symlink parent folder ''%s''', link_parent)
        os.makedirs(link_parent)

    os.symlink(target_final, link)
    if not os.path.samefile(link, target):
        raise exceptions.UnexpectedError(f"Unexpected mismatch when testing new symlink '{link_orig}' -> '{target_orig}'")

    #... do somethign with 'last' = self.db.get(where('last') != None)

    # db.remove(query.link == link)
#$$$    db.insert({'link': link, 'last': _db.})

    # TODO: at end of program...
    # 1. find all unused but managed links and delete them
    # 2. warn about all unmanaged links found in all parent folders of links

    return LinkResult.CREATED
