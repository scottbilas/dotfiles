## BASICS

	$ sudo apt install elinks

## SHELL

	# TEMP: needed to accept fix from https://github.com/fish-shell/fish-shell/pull/3922 (switch back to official release once this is in)
	$ sudo add-apt-repository ppa:fish-shell/nightly-master
	$ sudo apt update
	$ sudo apt install fish=2.5.0-291-gcc3efcc-1~xenial

	## $ sudo apt-add-repository -y ppa:fish-shell/release-2
	## $ sudo apt update
	## $ sudo apt install fish
	
	# install fisherman
	$ curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher

	# install fish plugins
	$ fisher fzf shark omf/theme-bobthefish decors/fish-ghq
	$ __fzf_install

## NVIM

	# install nvim
	$ sudo apt install neovim

## DEV TOOLS

	$ sudo apt-add-repository -y ppa:mercurial-ppa/releases
	$ sudo apt update

	$ sudo apt install autoconf gettext clang cmake silversearcher-ag python-pip python3-pip python-pygments mercurial weechat borgbackup

	$ pip install --upgrade pip
	$ pip3 install --upgrade pip

## INSTALL WEECHAT

	$ sudo pip install websocket-client
	$ wget https://raw.githubusercontent.com/rawdigits/wee-slack/master/wee_slack.py
	$ mv wee_slack.py ~/.weechat/python/autoload

## INSTALL GO

	# check `apt list golang` and see if < 1.8, add repo if so
	$ sudo add-apt-repository ppa:longsleep/golang-backports
	$ sudo apt update

	$ sudo apt install golang-go

## INSTALL GO UTILS

	$ go get github.com/motemen/ghq 
	$ go get github.com/nf/deadleaves
