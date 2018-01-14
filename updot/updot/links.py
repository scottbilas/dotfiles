import logging
import os
from enum import Enum, auto

from tinydb import Query

import updot
from updot._db import db


def _normalize_path(path):
    # check slashes before we expand tilde
    if '\\' in path:
        raise updot.exceptions.PathInvalidError(path, 'Paths must contain forward slashes only (simplify xplat issues)')

    path = os.path.expanduser(path)  # expand tilde before we check absolute

    if not os.path.isabs(path):
        raise updot.exceptions.PathInvalidError(path, 'Paths must be home-based or absolute (avoid potential for errors from unclear cwd)')

    # replace macros
    # TODO: expand $() style macros with env vars, throwing on not exist

    # ~ replacement and general cleanup
    path = os.path.normpath(path)

    # python path funcs will use backslash, so swap it back
    path = path.replace('\\', '/')

    # TODO: if windows-style path (\\unc\path or C:\blah), then for each level of path that exists, validate that the actual case matches what we have
    # (see answers in https://stackoverflow.com/a/35229734/14582 for ideas)

    return path


class LinkResult(Enum):
    SKIPPED = auto()    # didn't do anything
    CREATED = auto()    # created a new link
    ADJUSTED = auto()   # recreated an existing managed link to point to a new target


def ln(link, target):
    link_orig, link = link, _normalize_path(link)
    target_orig, target = target, _normalize_path(target)  # TODO: catch env var not exist and silent ignore

    # a missing target file is ok; common due to plat and install differences
    if not os.path.exists(target):
        logging.debug('Symlink target %s does not exist; skipping', target_orig)
        return LinkResult.SKIPPED

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

    linkparent = os.path.split(link)
    if not os.path.exists(linkparent):
        logging.debug('Creating symlink parent folder %s', linkparent
        os.makedirs(linkparent)

    os.symlink(target, link)

    query = Query()
    db.remove(query.link == link)
    db.insert({'link': link, 'query'})

    # TODO: at end of program...
    # 1. find all unused but managed links and delete them
    # 2. warn about all unmanaged links found in all parent folders of links

