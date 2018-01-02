from os import path

def symlink(self, target, link):
    spec = {'target': target, 'link': link}
    # TODO: check dupes
    # TODO: check target exist
    # TODO: check link not exist (or already points at requested target)
    #           if already exist, and it was moved, can use the state db to remember "this is a managed link" and just update without asking
    # TODO: make dirs up to link parent
    if not path.exists(target):
        return

    self.symlinks.append(spec)

    # create by default
    # notify of extra symlinks found in given base folder
    # offer to ignore forever (stores in local state file)
    # otherwise user will have to add to updot spec to say conditions where it's expected
    # update state file as we go
    # if fail to create symlink with permission problem, tell user to go enable developer mode (or sudo this)
