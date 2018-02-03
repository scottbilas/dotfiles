import logging
import os
from enum import Enum, auto

from tinydb import where

from updot import _db, exceptions

# TODO: at end of program...
# 1. find all unused but managed links and delete them from db (atexit)
# 2. warn about all unmanaged links found in all parent folders of links (perhaps manual call)


def _normalize_path(path):
    path_orig = path

    # check slashes before we expand tilde
    if '\\' in path:
        raise exceptions.PathInvalidError('Paths must contain forward slashes only (simplify xplat issues)', path=path_orig)

    # check user-tilde before expansion (see docs on `os.expanduser` to see how unix differs from win)
    if path[0] == '~' and len(path) > 1 and path[1] != '/':
        raise exceptions.PathInvalidError('Tilde-based paths that select a user are not xplat-friendly and therefore disallowed', path=path_orig)

    # expand macros before we check absolute
    path = os.path.expanduser(path)
    if '$' in path:
        # TODO: expand $ style macros with env vars, throwing MacroNotFoundError if not exist
        raise exceptions.PathInvalidError('"$ macro" expansion not currently supported', path=path_orig)

    # general cleanup
    path = os.path.normpath(path)

    # this is mostly a stylistic choice at this point, but i also think it will help avoid
    # accidental cross plat problems.
    if not os.path.isabs(path):
        raise exceptions.PathInvalidError('All paths (after expansion) must be absolute', path=path_orig)

    # python path funcs will use backslash, so swap it back
    path = path.replace('\\', '/')

    # TODO: if windows-style path (\\unc\path or C:\blah), then for each level of path that exists,
    # validate that the case of the path on disk matches exactly what `path` has. point of this is
    # to catch potential failures going from windows to linux (going the other way would be fine).
    # though..consider whether to warn about multiple symlinks in the same folder with same name but
    # different casing.
    # (see answers in https://stackoverflow.com/a/35229734/14582 for ideas)

    return path


class _LinksDb:
    def __init__(self, db=None):
        self.db = db if db else _db.get_shared_db()
        self.links = self.db.db.table('links')

    # utils

    def is_valid_serial(self, serial):
        return 1 <= serial <= self.db.serial

    def resolve_serial(self, serial):
        if serial is None:
            serial = self.db.serial
        elif not 1 <= serial <= self.db.serial:
            raise exceptions.DbError(f'Given `serial` ({serial}) is out of bounds of current serial ({self.db.serial})')
        return serial

    def make_link(self, link, target, last=None):
        last = self.resolve_serial(last)
        return {'link': link, 'target': target, 'last': last}

    # db

    def add(self, link, target, last=None):
        if self.find(link):
            raise exceptions.DbError(f'Unexpected existing link ''{link}''')
        self.links.insert(self.make_link(link, target, last))

    def add_or_update(self, link, target, last=None):
        self.links.upsert(self.make_link(link, target, last), where('link') == link)

    def find(self, link):
        found = self.links.get(where('link') == link)

        if found:
            last = found['last']
            if last > self.db.serial:
                raise exceptions.DbError(f'Found entry has `last` ({last}) out of bounds of current serial ({self.db.serial})')

        return found


class LinkResult(Enum):
    NO_TARGET = auto()      # target doesn't exist, so didn't do anything
    LINK_OK = auto()        # link created/moved/exists and points at correct target
    LINK_MISMATCH = auto()  # link already existed but was unmanaged and pointed at wrong target


# TODO: optional 'exe' param to test if in path and skip making link if not (for example dont clutter with ~/.tmux.conf if no tmux installed)
def ln(link, target):
    link_orig, link = link, _normalize_path(link)
    target_orig, target = target, _normalize_path(target)  # TODO: catch env var not exist and silent ignore

    # a missing target file is ok; common due to plat and install differences, so early-out
    if not os.path.exists(target):
        logging.debug('Symlink target ''%s'' does not exist; skipping', target_orig)
        return LinkResult.NO_TARGET

    # special: if both home-relative, make them relative to each other (shortens `ls`)
    target_final = target
    if link_orig.startswith('~/') and target_orig.startswith('~/'):
        target_final = os.path.relpath(target, os.path.split(link)[0]).replace('\\', '/')

    links_db = _LinksDb()
    managed = links_db.find(link)
    result = None

    # fetch existing link
    # TODO:
    #   * if either empty or identical contents to new target, or empty, offer to user to take ownership and replace with link
    #   * if file and mismatched, maybe show first 10 lines and make same offer (user may not care what's already there)
    target_existing = os.readlink(link) if os.path.exists(link) else None

    # link exists and matches
    if target_existing == target_final:
        result = LinkResult.LINK_OK
        if managed:
            logging.debug('Skipping managed symlink ''%s''->''%s''', link_orig, target_existing)
        else:
            logging.info('Taking ownership of existing symlink ''%s''->''%s''', link_orig, target_existing)
    # link exists but points somewhere else
    elif target_existing != None:
        if managed:
            logging.info('Moving managed symlink ''%s''->''%s''', link_orig, target_existing)
            os.remove(link)
            target_existing = None
        else:
            logging.error('Unmanaged symlink found ''%s''->''%s''', link_orig, target_existing)
            result = LinkResult.LINK_MISMATCH

    if result != LinkResult.LINK_MISMATCH:

        # (re-)create symlink if needed
        if target_existing != target_final:

            # first ensure we have a folder to put it in
            link_parent = os.path.split(link)[0]
            if not os.path.exists(link_parent):
                logging.info('Creating parent folder ''%s''', link_parent)
                os.makedirs(link_parent)

            logging.info('Creating symlink ''%s''->''%s''', link_orig, target_final)
            os.symlink(target_final, link)
            if not os.path.samefile(link, target):
                raise exceptions.UnexpectedError(f"Unexpected mismatch when testing new symlink '{link_orig}' -> '{target_orig}'")

        # add new, or if existing, mark as 'seen' (for later culling)
        links_db.add_or_update(link, target_final)
        result = LinkResult.LINK_OK

    return result
