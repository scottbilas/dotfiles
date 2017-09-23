_move this stuff to an install.sh/ps1_

# Installing dotfiles

```
# prereqs
apt install fish go openssh git
## special: wsl requires pull and build/install openssh

# clone
cd ~
git clone git@github.com:scottbilas/dotfiles.git

# setup ssh
mkdir .ssh
cp dotfiles/special/ssh/config .ssh/config
chmod 700 .ssh
chmod 600 .ssh/config

# install ghq
go get github.com/motemen/ghq

# install fzf
ghq get junegunn/fzf
ghq look fzf
termux-fix-shebang install
install
exit

# install omf
curl -L https://get.oh-my.fish | fish
```
# Links

### General

```
~/.config -> ~/dotfiles/config                  # consider using $XDG_CONFIG_HOME
~/.tmux.conf -> ~/.config/tmux/tmux.conf        # tmux devs refuse to support XDG; use aliasing and 'tmux -f' instead
```

### Windows-only

```
~/.gitconfig -> ~/.config/git/config            # always under HOME unfortunately
```
