from updot import platform

def test__detected_platforms__do_not_collide():
    """Ensure platforms' dependencies and mutual exclusion requirements are met"""

    os_count = platform.POSIX + platform.WINDOWS
    posix_count = platform.WSL + platform.TERMUX + platform.CYGWIN

    assert os_count == 1                    # support either posix or windows
    assert platform.POSIX == posix_count    # if posix, expect exactly one posix subplat, otherwise must be none
