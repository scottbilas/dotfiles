class UpdotError(Exception):
    """Base updot exception"""
    pass

class PathInvalidError(UpdotError):
    """The path is invalid"""
    def __init__(self, path, reason):
        self.path = path
        self.reason = reason
