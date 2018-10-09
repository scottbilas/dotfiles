mkdir -p ~/.local/share/zsh

# basics

export EDITOR='micro'
export VISUAL='micro'
export PAGER='less'
export GOPATH="$HOME/go"
export GIT_SUBREPO_ROOT="$HOME/.config/git/git-subrepo"
export FZF_DEFAULT_OPTS="--tabstop=4 --preview='head -$LINES {}' --preview-window=right:40% --bind 'alt-p:toggle-preview'"

# needed if dasht not installed via a package mamager
export MANPATH="$HOME/extern/dasht/man:$MANPATH"

# termux's elinks does not like ~/.config; something seems wrong
export ELINKS_CONFDIR='.config/elinks'

# less

export LESS='-F -g -i -M -R -w -X -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

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
