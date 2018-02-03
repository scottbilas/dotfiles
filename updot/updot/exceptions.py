class UpdotError(Exception):
    """Base updot exception"""
    pass

class PathInvalidError(UpdotError):
    """The path is invalid"""

    def __init__(self, message, path):
        super().__init__(message)
        self.path = path


class DbError(UpdotError):
    """General updot database related error"""
    pass


class UnexpectedError(UpdotError):
    """Something happened that the code wasn't expecting"""
    pass
