_move this stuff to an install.sh/ps1_

# Installing dotfiles

```
# core prereqs
apt install fish go openssh git micro nvim
## special: wsl requires pull and build/install openssh

# clone
cd ~
git clone git@github.com:scottbilas/dotfiles.git

# link
ln -s ~/dotfiles/config ~/.config               # consider using $XDG_CONFIG_HOME
ln -s ~/.config/tmux/tmux.conf ~/.tmux.conf     # tmux devs refuse to support XDG; TODO: use aliasing and 'tmux -f' instead
ln -s sync:Common/Private ~/dotfiles/private

# link (windows only)
mklinkd ~/.config/git/config ~/.gitconfig       # always under HOME unfortunately

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
