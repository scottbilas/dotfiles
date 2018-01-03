from os import path

def symlink(self, target, link):
    spec = {'target': target, 'link': link}
    # # TODO: make dirs up to link parent
    if not path.exists(target):
        return

    self.symlinks.append(spec)

    # update state file as we go
