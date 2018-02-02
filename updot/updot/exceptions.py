class UpdotError(Exception):
    """Base updot exception"""

    def __init__(self, reason):
        super().__init__()
        self.reason = reason


class PathInvalidError(UpdotError):
    """The path is invalid"""

    def __init__(self, path, reason):
        super().__init__(reason)
        self.path = path


class DbError(UpdotError):
    """General updot database related error"""
    pass


class UnexpectedError(UpdotError):
    """Something happened that the code wasn't expecting"""
    pass
