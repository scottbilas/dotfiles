class UpdotError(Exception):
    """Base updot exception"""
    pass

class PathInvalidError(UpdotError):
    """The path is invalid"""

    def __init__(self, message, path):
        super().__init__(message)
        self.path = path


class MacroExpansionError(PathInvalidError):
    """The macro within a path is invalid or used improperly"""

    def __init__(self, message, macro_name, macro_value, outer_path):
        super().__init__(message, outer_path)
        self.macro_name = macro_name
        self.macro_value = macro_value


class DbError(UpdotError):
    """General updot database related error"""
    pass


class UnexpectedError(UpdotError):
    """Something happened that the code wasn't expecting"""
    pass
