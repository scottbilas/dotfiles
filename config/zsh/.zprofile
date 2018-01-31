mkdir -p ~/.local/share/zsh

# basics

export EDITOR='micro'
export VISUAL='micro'
export PAGER='less'
export GOPATH="$HOME/go"

# less

export LESS='-F -g -i -M -R -S -w -X -z-4'

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

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

cdpath=(
  $cdpath
  ~
)

path=(
  /usr/local/{bin,sbin}
  $path
  $GOPATH/bin
)
