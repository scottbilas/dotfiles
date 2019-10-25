mkdir -p ~/.local/share/zsh

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
export FZF_DEFAULT_OPTS="--tabstop=4 --preview-window=right:60% --bind 'alt-p:toggle-preview' --preview 'bat --color=always {} | head -500'"
export FZF_DEFAULT_COMMAND="rg --hidden --files -g \!.git"
export BAT_CONFIG_PATH="$HOME/.config/bat/bat.conf"
export MICRO_TRUECOLOR=1

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

# fix unreadable background on wsl
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
  ~/bin
  $GOPATH/bin

  # TODO: symlink the commands for these instead
  $GIT_SUBREPO_ROOT/lib
  ~/extern/dasht/bin
)

#####

source ~/.config/zsh/.zprezto/init.zsh
source ~/.config/zsh/.p10k.zsh
source ~/.config/zsh/zaliases

# Finalize Powerlevel10k instant prompt. Should stay at the bottom of this file.
#(( ! ${+functions[p10k-instant-prompt-finalize]} )) || p10k-instant-prompt-finalize
