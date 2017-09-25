_move this stuff to an install.sh/ps1_

# Minimum requirements

* openssh 7.3p1+ ('Include' directive)
* tmux 2.2+ (24-bit color)
** xenial instructions:
** `apt install libevent-dev ncurses-dev`
** `ghq get tmux; ghq look tmux`
** `sh autogen.sh; ./configure; sudo make install`

# Installing dotfiles

```
# wsl/xenial prep
sudo add-apt-repository ppa:git-core/ppa
    ## TODO: others
    #http://linux-packages.resilio.com/resilio-sync/debresilio-sync/non-free
    #http://ppa.launchpad.net/fish-shell/nightly-master/ubuntuxenial/main
    #http://ppa.launchpad.net/fish-shell/release-2/ubuntuxenial/main
    #http://ppa.launchpad.net/longsleep/golang-backports/ubuntuxenial/main
    #http://ppa.launchpad.net/mercurial-ppa/releases/ubuntuxenial/main
    #http://ppa.launchpad.net/neovim-ppa/stable/ubuntuxenial/main
    #https://apt.dockerproject.org/repoubuntu-xenial/main
sudo apt update

# core prereqs
apt install fish go openssh git micro nvim coreutils
## special: wsl requires pull and build/install openssh (unless can figure out how to get from xenial-backports)

# clone
cd ~
git clone git@github.com:scottbilas/dotfiles.git

# setup ssh
mkdir .ssh
cp dotfiles/special/ssh/config .ssh/config
chmod 700 .ssh
chmod 600 .ssh/config
chmod 600 .config/ssh/config

# link
ln -s ~/dotfiles/config ~/.config                                     # consider using $XDG_CONFIG_HOME
ln -s ~/dotfiles/private/ssh/authorized_keys ~/.ssh/authorized_keys
ln -s ~/.config/tmux/tmux.conf ~/.tmux.conf                           # tmux devs refuse to support XDG; TODO: use aliasing and 'tmux -f' instead
ln -s sync:Common/Private ~/dotfiles/private

# link (windows only)
mklinkf ~/.config/git/config-windows ~/.gitconfig                     # windows overrides
mklinkd ~/dotfiles/special/vscode/User $env:APPDATA/Code/User

# link (cygwin only)
ln -s ~/dotfiles/special/cygwin/profile ~/.profile
ln -s ~/dotfiles/special/cygwin/minttyrc ~/.minttyrc

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

# Setting up tools

## VSCode

* C/C++
* C#
* Code Spell Checker
* Cram Test Language Support
* Debugger for Unity
* EditorConfig for VS Code
* Fish shell
* Git Lens
* Guides
* LLDB Debugger
* Local History
* markdownlint
* Mono Debug
* PowerShell
* Python
* TODO Highlight
* vscode-icons
* XML Tools

## Cygwin

* Save installer to c:\cygwin64 and run
  * Accept defaults
  * Add `wget` package
* Open cyg terminal and do
  ```
  cat >> /etc/nsswitch.conf
  db_home: windows
  <Ctrl-D>
  ln -s /cygdrive/c /c # etc
  ```
* Install apt-cyg
  ```
  wget rawgit.com/transcode-open/apt-cyg/master/apt-cyg
  install apt-cyg /bin
  rm apt-cyg
  ```
* `apt-cyg install nano vim openssh git`
* Open cyg terminal as admin and do
  * `ssh-host-config -y` (use password from LastPass)
  * `nano /etc/sshd_config` and reset StrictModes to off (hate fighting cygwin-home permissions)
  * `cygrunsrv -S sshd`
