mkdir -p ~/.local/share/zsh
mkdir -p ~/.local/bin

# Enable Powerlevel10k instant prompt. Should stay at the top of this file.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

## ENVIRONMENT

# general

export EDITOR='micro'
export VISUAL='micro'
export PAGER='less'

# tune apps and environments

export GOPATH="$HOME/go"
export FZF_DEFAULT_OPTS="--tabstop=4 --preview-window=right:60% --bind 'alt-p:toggle-preview' --preview '(bat --color=always {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -500'"
# debian: sudo apt install fd-find && sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
export FZF_DEFAULT_COMMAND="fd --hidden -E .git"
export FZF_TMUX=1
export BAT_CONFIG_PATH="$HOME/.config/bat/bat.conf"
export MICRO_TRUECOLOR=1
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# needed if dasht not installed via a package mamager
#TODO: check exist dasht
export MANPATH="$HOME/extern/dasht/man:$MANPATH"

# move out of root, and folder must exist
mkdir -p ~/.local/share/fasd
export _FASD_DATA="$HOME/.local/share/fasd/data"

# termux's elinks does not like ~/.config; something seems wrong
export ELINKS_CONFDIR='.config/elinks'

# less
export LESS='-F -g -i -M -R -w -X -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# fix unreadable background on wsl when doing tab-completion for dirs
LS_COLORS+=':ow=01;33'

# other

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

# completion

# TODO: figure out why getting compdef error after uncommenting below
# (see https://github.com/sorin-ionescu/prezto/issues/1138)
# bash compatibility
#autoload -U bashcompinit && bashcompinit
#
#if [[ $(type -p az) ]]; then
#    . ~/lib/azure-cli/az.completion
#fi

[[ $- == *i* ]] && source "$HOME/.config/fzf/fzf/shell/completion.zsh" 2> /dev/null
source "$HOME/.config/fzf/fzf/shell/key-bindings.zsh" 2> /dev/null
### FIX ME ^^ drop the /dev/null routing of errors

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

cdpath=(
  $cdpath
  ~
)

path=(
  /usr/local/{bin,sbin}
  $path
  ~/.local/bin
  $GOPATH/bin
  ~/extern/dasht/bin
)

#####

source ~/.config/zsh/.zprezto/init.zsh
source ~/.config/zsh/.p10k.zsh
[[ -d ~/.poetry ]] && source ~/.poetry/env
#todo: check this works
#fpath+=~/extern/dasht/etc/zsh/completions/


# Finalize Powerlevel10k instant prompt. Should stay at the bottom of this file.
#(( ! ${+functions[p10k-instant-prompt-finalize]} )) || p10k-instant-prompt-finalize

# doesn't work for some reason
# maybe because expecting zshrc? should just rename zprofile to zshrc..?
typeset -g POWERLEVEL9K_DISABLE_INSTANT_PROMPT=true

#####

source ~/.config/zsh/zplugin/zplugin.zsh

ZPLGM[PLUGINS_DIR]="$HOME/.local/share/zplugin/plugins"
ZPLGM[COMPLETIONS_DIR]="$HOME/.local/share/zplugin/completions"
ZPLGM[ZCOMPDUMP_PATH]="$HOME/.local/share/zplugin/.zcompdump"

zplugin ice atclone"dircolors -b LS_COLORS > c.zsh" atpull'%atclone' pick"c.zsh"
zplugin load trapd00r/LS_COLORS

#zplugin load wookayin/fzf-fasd

#### LAST

# keep these last so they override any modules

## OPTIONS

unsetopt autocd
unsetopt banghist
unsetopt cdablevars

## aliases

source ~/.config/zsh/zaliases
