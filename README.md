# Scott Bilas's dotfiles

I've been evolving my personal dev environment over the decades, migrating forward scripts from 4DOS and 4NT when I was a kid and into Powershell. Everything has stayed in sync via whatever worked best at the time - Live Mesh, Cubby, and currently Resilio.

Recently Windows conventions have been leaning away from the registry and toward dotfiles, I've been getting into Linux a bit, and GitHub has a thing for dotfiles. So here's mine. I'm slowly moving publishable things out of the sync, cleaning it up, pushing it. Over time I hope to bend most of the Powershell scripts into something more universally portable, probably Python.

These dotfiles are intended to work across the few environments I care about, currently:

* Windows/PowerShell
* Termux
* Ubuntu (usually via WSL, currently 16.04LTS/xenial)
* MSYS (via Windows git)
* Cygwin (minimal, with shared HOME to Windows host) << marked for destruction

TODO: move some of this stuff to an install.sh/ps1 or use something from _General-purpose dotfile utilities_ at [GitHub does dotfiles](https://dotfiles.github.io).

Thanks to [Anish Athalye](www.anishathalye.com) for the inspirational post [Managing Your Dotfiles](http://www.anishathalye.com/2014/08/03/managing-your-dotfiles).

## System Prep (unix)

### Xenial

```bash
sudo add-apt-repository ppa:git-core/ppa
sudo add-apt-repository http://ppa.launchpad.net/fish-shell/release-2/ubuntuxenial/main
sudo add-apt-repository http://ppa.launchpad.net/neovim-ppa/stable/ubuntuxenial/main
sudo add-apt-repository http://ppa.launchpad.net/mercurial-ppa/releases/ubuntuxenial/main
sudo add-apt-repository http://ppa.launchpad.net/longsleep/golang-backports/ubuntuxenial/main
sudo add-apt-repository http://linux-packages.resilio.com/resilio-sync/debresilio-sync/non-free
sudo add-apt-repository https://apt.dockerproject.org/repoubuntu-xenial/main
sudo apt update
```

### Cygwin

TODO: look up installer url

* Save installer exe to `c:\cygwin64` and run it
  * Accept defaults
  * Add `wget` package
* Open cyg terminal and do
  ```bash
  cat >> /etc/nsswitch.conf
  db_home: windows
  <Ctrl-D>
  ln -s /cygdrive/c /c # etc
  ```
* Install apt-cyg
  ```bash
  wget rawgit.com/transcode-open/apt-cyg/master/apt-cyg
  install apt-cyg /bin
  rm apt-cyg
  ```

### Minimum packages

```bash
sudo apt install -y coreutils git
```

## System Prep (windows)

```powershell
# scoop
iwr https://get.scoop.sh -usebasic | iex
scoop install git
scoop bucket add extras
scoop install sudo busybox less # note that `less` overrides `busybox` with a better version

# chocolatey
sudo powershell "iwr https://chocolatey.org/install.ps1 -usebasic | iex"
<restart shell>
```

## Bootstrap

### Git em

```bash
cd ~
git clone --recursive https://github.com/scottbilas/dotfiles
```

### Wire up

```bash
# common
mkdir ~/bin
mkdir -p ~/go/bin
ln -s sync:Common/Private ~/dotfiles/private
ln -s ~/dotfiles/config ~/.config
mkdir ~/.ssh
ln -s ~/dotfiles/private/ssh/authorized_keys ~/.ssh/authorized_keys
ln -s ~/.config/tmux/tmux.conf ~/.tmux.conf
touch ~/.hushlogin

# termux only
ln -s ~/dotfiles/config/termux ~/.termux

# cygwin only
ln -s ~/dotfiles/special/cygwin/profile ~/.profile
ln -s ~/dotfiles/special/cygwin/minttyrc ~/.minttyrc
```

```powershell
# windows only (posh)
mklinkf ~/.config/git/config-windows ~/.gitconfig
mklinkf ~/.config/hg/hgrc ~/.hgrc    # XDG config code only runs on hg's posix code path
mklinkd ~/dotfiles/special/vscode/User $env:APPDATA/Code/User
mklinkd ~/dotfiles/config/omnisharp ~/.omnisharp

powershell # open nested shell
  . ~/scoop/apps/scoop/current/lib/core.ps1 # get shim func
  shim ~/DevBin/hg/hg.exe
  shim ~/DevBin/hg/thg.exe
exit

# TODO: disable path inheritance (https://github.com/Microsoft/BashOnWindows/issues/1493)
# reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Lxss /v AppendNtPath /t REG_DWORD /d 0
# TOOD: fix default env at Computer\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\{5a935a5c-5e58-463d-9f50-fb91be9fd0bb}\DefaultEnvironment
# another option is ignore entirely. just copy out what i want from default env and overwrite completely. simplest.
```

TODO: use aliasing of `tmux -f` instead of ln on tmux.conf (tmux devs [refuse to support XDG](https://github.com/tmux/tmux/issues/142))

### Fish

```bash
sudo apt install -y fish
chsh -s `which fish`
```

Then restart shell as Fish.

```fish
# install omf
# TODO: dotfiles should do this instead..maybe call 'fisher' instead post-install?
#curl -L https://get.oh-my.fish | fish
```

## Basics

### ghq

```fish
sudo apt install -y golang
go get github.com/motemen/ghq
```

### Tmux

Is `tmux -V` < 2.2? If not, need to build it to get support for 24-bit color.

```fish
# xenial
apt install -y libevent-dev ncurses-dev
ghq get tmux; ghq look tmux
sh autogen.sh; ./configure; sudo make install
exit
```

### Ssh

Is `ssh -V` >= 7.3p1? If not, need to build it to get support for the _Include_ directive.

#### Build recent ssh

```bash
sudo apt install -y build-essential libssl-dev zlib1g-dev
wget https://mirror.one.com/pub/OpenBSD/OpenSSH/portable/openssh-7.5p1.tar.gz
tar xfz openssh-7.5p1.tar.gz
cd openssh-7.5p1
./configure && make && sudo make install
hash -r # tell session to find new ssh
cd ..
rm -rf openssh-7.5p1*
```

TODO: (xenial) find backport package instead to avoid needing to build

#### Config ssh

```bash
mkdir .ssh
cp dotfiles/special/ssh/config .ssh/config
chmod 700 .ssh
chmod 600 .ssh/config
chmod 600 .config/ssh/config

# fix git now that we've got ssh going
cd dotfiles
git remote remove origin
git remote add origin git@github.com:scottbilas/dotfiles
cd ~
```


------

## Optional Sections

### Editor

```bash
# termux
apt install micro nvim

# other
curl -sL https://gist.githubusercontent.com/zyedidia/d4acfcc6acf2d0d75e79004fa5feaf24/raw/a43e603e62205e1074775d756ef98c3fc77f6f8d/install_micro.sh | bash -s linux64 ~/bin
sudo apt install nvim
```

# fzf

```bash
ghq get junegunn/fzf
ghq look fzf
./install
exit
```

## Tools

```sh
pip install tldr ptpython
```

### Misc

See https://github.com/lukesampson/scoop/wiki/Example-Setup-Scripts

### VSCode

TODO: auto sync this stuff, yo

* Align
* Auto Close Tag
* Auto Rename Tag
* Better TOML
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
* Ruby
* TODO Highlight
* vscode-devdocs
* vscode-icons
* XML Tools
* YAML

### sshd

Open mintty as admin and:

```bash
apt-cyg install nano openssh
ssh-host-config -y      # use password from LastPass
nano /etc/sshd_config   # reset StrictModes to off (gave up fighting cygwin-home permissions)
cygrunsrv -S sshd
```
