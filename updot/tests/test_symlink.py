import os
import pyfakefs

pyfakefs.deprecator.Deprecator.show_warnings = True

# pylint: disable=relative-beyond-top-level
#from .context import updot

def test_fake_fs(fs):

    # "fs" is the reference to the fake file system
    fs.create_file('/var/data/xx1.txt')
    assert os.path.exists('/var/data/xx1.txt')
