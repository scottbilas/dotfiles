import os
import pyfakefs

pyfakefs.deprecator.Deprecator.show_warnings = True

# pylint: disable=relative-beyond-top-level, invalid-name
#from .context import updot

def test__tracked_link_exists_with_correct_target__ignores():
    """Rebuilding an existing symlink should do nothing"""
    pass

def test__untracked_link_exists_with_correct_target__tracks_and_ignores():
    """Should take over an already-correct symlink"""
    # test addition to state db
    pass

def test__tracked_link_exists_with_different_target__updates():
    """A symlink we were tracking has changed in spec, so update the symlink"""
    # test update to state db
    pass

def test__untracked_link_exists_with_different_target__throws():
    """Symlink already exists and is pointing somewhere unexpected"""
    pass

def test__link_not_exist_and_target_exists__creates_and_tracks():
    """Basic behavior of creating new symlinks"""
    # test addition to state db
    pass

def test__target_not_exist__ignores():
    """Ignore symlinks referring to nonexistent target paths (will be very common across OS's)"""
    pass

def test__dup_target_and_link__throws():
    """Catch accidental duplication of symlinks"""
    pass

def test__unspecified_symlinks_found_in_any_link_parent__warns():
    """Detect when user has added symlinks manually and forgotten to update spec"""
    # FUTURE: offer to add to spec
    # FUTURE: offer to ignore future warnings about this (store in local state file)
    pass

def test__windows_symlink_creation_failed_due_to_no_admin__fatals_with_help():
    """Let user know they should enable Developer Mode or run as admin"""
    # should be a permissions problem that leads to this
    pass


# "fs" is the reference to the fake file system
# def test_func(fs):
#   fs.create_file('/var/data/xx1.txt')
#   assert os.path.exists('/var/data/xx1.txt')
