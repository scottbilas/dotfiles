import logging
import os
import re
from enum import Enum, auto

from tinydb import where

from updot import _db, exceptions, platform

# TODO: at end of program...
# 1. find all unused but managed links and warn (atexit)
#    - ask user per link if should delete from hdd too (could imply a ln we don't want any more from a previous iteration of the user's updot script)
#    - delete from db if user says either ignore or delete, otherwise leave for next time
# 2. warn about all unmanaged links found in all parent folders of links (perhaps manual call)

# general note on xplat case sensitivity:
#
# many functions are case-insensitive on windows that are not so on posix, which adds xplat bug
# potential in user scripts. for example, accidentally using the wrong case in `$Home/some/path`,
# which 'works', may surprise when the same code fails on linux.
#
# therefore, updot function where there is a case-sensitivity difference between platforms, the
# policy is to restrict to the least common denominator, encoded in a simple rule:
#
# -- the counts of case-sensitive and -insensitive matches should both equal exactly 1 --


def _normalize_path(path):
    path_orig = path

    if not path:
        raise exceptions.PathInvalidError('Paths cannot be empty or missing', None)
    if re.search(r'\\(?!\$)', path):
        raise exceptions.PathInvalidError('Paths must contain forward slashes only (except when escaping `$`)', path_orig)

    def lookup(match):
        if match.group(1):
            return match.group(0)

        name = match.group(2)
        value = None

        try:
            value = os.environ[name]
        except KeyError:
            pass

        if not value:
            raise exceptions.MacroExpansionError(
                f'Macro \'{name}\' not found (or empty)', name, None, path_orig)

        if os.path.isabs(value) and match.start(0) != 0:
            raise exceptions.MacroExpansionError(
                f'Macro \'{name}\' refers to an absolute path, but is not used from the start of the path it is used in', name, value, path_orig)

        # `environ[]` has case-sensitivity behavior differences on windows vs posix, so test and warn

        name_folded = name.casefold()
        icase_matches = [key for key in os.environ.keys() if key.casefold() == name_folded]
        assert icase_matches, 'sanity check'

        if len(icase_matches) > 1:
            raise exceptions.MacroExpansionError(
                f'Macro {name} has multiple case-insensitive env matches', name, value, path_orig)

        if name != icase_matches[0]:
            raise exceptions.MacroExpansionError(
                f'Macro {name} does not match case of actual env name {icase_matches[0]}', name, value, path_orig)

        return value

    # replace macros and clean up any escaped $'s
    # TODO: consider using os.path.expandvars in here somewhere
    path = re.sub(r'(\\)?\$([A-Za-z]\w*)', lookup, path)
    path = path.replace('\\$', '$')

    # check user-tilde before tilde-expansion (see docs on `os.expanduser` to see how unix differs from win)
    if path[0] == '~' and len(path) > 1 and path[1] != '/':
        raise exceptions.MacroExpansionError(
            'Tilde-based paths that select a user are not xplat-friendly and therefore disallowed',
            path.split('/')[0], None, path_orig)

    # final expansion and cleanup
    path = os.path.expanduser(path)
    path = os.path.normpath(path)

    # this is mostly a stylistic choice at this point, but i also think it will help avoid
    # accidental xplat problems.
    if not os.path.isabs(path):
        raise exceptions.PathInvalidError('All paths (after expansion) must be absolute', path_orig)

    # various python path funcs (and possibly expanded macros) will use backslash, so ensure we swap it back
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
            raise exceptions.DbError(f'Unexpected existing link \'{link}\'')
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

    # special note on `lexists` - we usually do not want to "look through" a symlink for the target
    # file existence. because updot is going to get mixed with another tool syncing file moves (such
    # as a `git pull`) we need to be tolerant where `!exists && !exists` because updot is about to
    # resolve the intermediate conflicts.

    # a missing target file is ok; common due to plat and install differences, so early-out
    if not os.path.lexists(target):
        logging.debug('Symlink target \'%s\' does not exist; skipping', target_orig)
        return LinkResult.NO_TARGET

    # don't symlink to yourself. note that we `realpath` just the parent dir
    # and not all of `link` in case the symlink already exists, in which case
    # `realpath` would resolve it too far.
    link_parent, link_filename = os.path.split(link)
    link_realpath = os.path.join(os.path.realpath(link_parent), link_filename).replace('\\', '/')
    if link_realpath == os.path.realpath(target):
        raise exceptions.PathInvalidError(f'Symlink points at itself \'{link}\'->\'{target}\'', os.path.realpath(link))

    # special: if both home-relative, make them relative to each other (shortens `ls`)
    target_final = target
    if link_orig.startswith('~/') and target_orig.startswith('~/'):
        target_final = os.path.relpath(target, os.path.split(link)[0]).replace('\\', '/')

    links_db = _LinksDb()
    managed = links_db.find(link)
    result = None

    if managed and managed['last'] == links_db.db.serial:
        raise exceptions.UpdotError(f'Duplicate creation of symlink \'{link}\'')

    # fetch existing link
    # TODO:
    #   * if either empty or identical contents to new target, or empty, offer to user to take ownership and replace with link
    #   * if file and mismatched, maybe show first 10 lines and make same offer (user may not care what's already there)
    #   * on windows, we have to care about whether it's a dir or file symlink, so should test for mismatch from expected and possibly track is-dir/file in the db
    target_existing = os.readlink(link) if os.path.lexists(link) else None

    # link exists and matches
    if target_existing == target_final:
        result = LinkResult.LINK_OK
        if managed:
            logging.debug('Skipping managed symlink \'%s\'->\'%s\'', link_orig, target_existing)
        else:
            logging.info('Taking ownership of existing symlink \'%s\'->\'%s\'', link_orig, target_existing)
    # link exists but points somewhere else
    elif target_existing != None:
        if managed:
            logging.info('Moving managed symlink \'%s\'->\'%s\'', link_orig, target_existing)
            os.remove(link)
            target_existing = None
        else:
            logging.error('Unmanaged symlink found \'%s\'->\'%s\'', link_orig, target_existing)
            result = LinkResult.LINK_MISMATCH

    if result != LinkResult.LINK_MISMATCH:

        # (re-)create symlink if needed
        if target_existing != target_final:

            # first ensure we have a folder to put it in
            if not os.path.exists(link_parent):
                logging.info('Creating parent folder \'%s\'', link_parent)
                os.makedirs(link_parent)

            logging.info('Creating symlink \'%s\'->\'%s\'', link_orig, target_final)
            os.symlink(target_final, link)
            if not os.path.samefile(link, target):
                raise exceptions.UnexpectedError(f"Unexpected mismatch when testing new symlink '{link_orig}' -> '{target_orig}'")

        # add new, or if existing, mark as 'seen' (for later culling)
        links_db.add_or_update(link, target_final)
        result = LinkResult.LINK_OK

    return result
