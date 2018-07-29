# Scott Bilas's dotfiles

I've been evolving my personal dev environment over the decades, migrating forward scripts from 4DOS and 4NT when I was a kid and into Powershell. Everything has stayed in sync via whatever worked best at the time - Live Mesh, Cubby, and currently Resilio.

Recently Windows conventions have been leaning away from the registry and toward dotfiles, I've been getting into Linux a bit, and GitHub has a thing for dotfiles. So here's mine. I'm slowly moving publishable things out of the sync, cleaning it up, pushing it. Over time I hope to bend most of the Powershell scripts into something more universally portable, probably Python.

These dotfiles are intended to work across the few environments I care about, currently:

* Windows/PowerShell
* Termux
* Ubuntu (usually via WSL, currently 16.04LTS/xenial)
* MSYS (via Windows git)
* Misc hosted containers with old LTS kernels, like from CodeAnywhere
* Cygwin (minimal, with shared HOME to Windows host) << marked for destruction

Thanks to [Anish Athalye](www.anishathalye.com) for the inspirational post [Managing Your Dotfiles](http://www.anishathalye.com/2014/08/03/managing-your-dotfiles).

## Barebones setup

### Unix

```bash
# unix
curl https://raw.githubusercontent.com/scottbilas/dotfiles/master/install/install.sh | bash

# powershell
iwr https://raw.githubusercontent.com/scottbilas/dotfiles/master/install/install.ps1 -useb | iex
```

---------------

## System Prep (unix)

Which?
```bash
~/dotfiles/scripts/meksysinfo
```

### Termux

```bash
pkg install wget
wget https://sdrausty.github.io/TermuxArch/setupTermuxArch.sh
bash setupTermuxArch.sh
bash arch/startarch
pacman -Syu

### Trusty (16.04 LTS)

```bash
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:jonathonf/python-3.6
sudo apt update

sudo apt install -y tmux man git zsh bc
sudo apt install -y golang python3.6
```

### Xenial

```bash
sudo add-apt-repository ppa:git-core/ppa
sudo add-apt-repository http://ppa.launchpad.net/neovim-ppa/stable/ubuntuxenial/main
sudo add-apt-repository http://ppa.launchpad.net/mercurial-ppa/releases/ubuntuxenial/main
sudo add-apt-repository http://ppa.launchpad.net/longsleep/golang-backports/ubuntuxenial/main
sudo add-apt-repository http://linux-packages.resilio.com/resilio-sync/debresilio-sync/non-free
sudo add-apt-repository https://apt.dockerproject.org/repoubuntu-xenial/main
sudo apt update
```

### Cygwin

```powershell
sudo cinst cyg-get
cyg-get <stuff>
```

```bash
# cygwin terminal
cat >> /etc/nsswitch.conf
db_home: windows<Ctrl-D>
<Updot>
```

### Minimum packages

```bash
sudo apt install -y coreutils git sed
```

## System Prep (windows)

```powershell
# scoop
scoop bucket add extras
scoop install sudo busybox win32-openssh concfg

# override busybox applets with better/newer versions
scoop install which less wget sed curl

# chocolatey
sudo powershell "iwr https://chocolatey.org/install.ps1 -usebasic | iex"
<restart shell>

# TODO: disable path inheritance (https://github.com/Microsoft/BashOnWindows/issues/1493)
# reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Lxss /v AppendNtPath /t REG_DWORD /d 0
# TOOD: fix default env at Computer\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\{5a935a5c-5e58-463d-9f50-fb91be9fd0bb}\DefaultEnvironment
# another option is ignore entirely. just copy out what i want from default env and overwrite completely. simplest.
```

## Basics

### ghq

```bash
sudo apt install -y golang
go get github.com/motemen/ghq
```

### Tmux

Is `tmux -V` < 2.2? If not, need to build it to get support for 24-bit color.

```bash
sudo apt install -y libevent-dev ncurses-dev
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
sudo apt install nvim golang

# micro
pushd
go get -d github.com/zyedidia/micro/cmd/micro
cd $GOPATH/src/github.com/zyedidia/micro
make install
popd

# alternate: direct bin install of micro
curl https://getmic.ro | bash
mv micro ~/bin/

```

# fzf

```bash
ghq get junegunn/fzf
ghq look fzf
./install
exit
```

# everything (Windows)

```powershell
scoop install everything
everything
```

* Ctrl-P (options)
* Check 'Store settings and data in %APPDATA%\Everything'
* Check 'Start Everything on system startup'
* Check 'Everything Service'
* Exit Everything

```powershell
sudo stop-service everything
mv ~\AppData\Roaming\Everything ~\AppData\Roaming\Everything.old
mklinkd -link ~\AppData\Roaming\Everything -folder ~\Programs\Everything
copy ~\Programs\Everything\Everything.ini ~\Programs\Everything\Everything.ini.bak # just in case
sudo start-service everything
everything
```

Test to ensure hotkey and exclusions are working.

## Tools

```sh
pip install --upgrade pip
pip install tldr ptpython pdbpp
```

### VSCode

# TODO: ln -s C:\Users\scott\dotfiles\special\vscode\User C:\Users\scott\scoop\persist\vscode-portable\data\user-data\User

TODO: auto sync this stuff, yo

```powershell
code --list-extensions | %{ '* ' + ($_.name -replace '-[0-9.]+$', '') } | clip
```

Can install the below with `code --install-extension <packagename>`

* 13xforever.language-x86-64-assembly
* 74th.monokai-charcoal-high-contrast
* adamvoss.yaml (not in marketplace..replace)
* akfish.vscode-devdocs
* anweber.vscode-tidyhtml
* bbenoist.vagrant
* bungcip.better-toml
* codezombiech.gitignore
* davidanson.vscode-markdownlint
* dotjoshjohnson.xml
* eamodio.gitlens
* editorconfig.editorconfig
* emilast.logfilehighlighter
* fabiospampinato.vscode-statusbar-debugger
* fallenwood.viml
* formulahendry.auto-close-tag
* formulahendry.auto-rename-tag
* foxundermoon.shell-format
* jtanx.ctagsx (disable)
* helixquar.asciidecorator
* k3a.theme-dark-plus-contrast
* lei.theme-chromodynamics
* lextudio.restructuredtext
* mihaipopescu.cram
* ms-python.python
* ms-vscode.cpptools
* ms-vscode.csharp
* ms-vscode.mono-debug
* ms-vscode.powershell
* robertohuertasm.vscode-icons
* slevesque.vscode-autohotkey
* spywhere.guides
* steve8708.align
* stkb.rewrap
* streetsidesoftware.code-spell-checker
* tristanremy.mirage
* unity.unity-debug
* vadimcn.vscode-lldb
* vscodevim.vim (disable)
* wayou.vscode-todo-highlight
* xyz.local-history

```bash
go get -u mvdan.cc/sh/cmd/shfmt  # for foxundermoon.shell-format
```

### sshd

Open mintty as admin and:

```bash
apt-cyg install nano openssh
ssh-host-config -y      # use password from LastPass
nano /etc/sshd_config   # reset StrictModes to off (gave up fighting cygwin-home permissions)
cygrunsrv -S sshd
```
