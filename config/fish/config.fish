# works except for git-commit style on termux
#set -x MICRO_TRUECOLOR 1

set -q PREFIX; or set -x PREFIX ""

set -x CONFIG_SHELL $PREFIX/bin/sh
if not test -e $CONFIG_SHELL
    echo "config.fish: CONFIG_SHELL does not exist"
end

set -x EDITOR $PREFIX/bin/micro
if not test -e $EDITOR
    set -x EDITOR ~/bin/micro
end
if not test -e $EDITOR
    echo "config.fish: EDITOR does not exist"
end

set -x ELINKS_CONFDIR ~/.config/elinks

# the fishy way of updating PATH
set -U fish_user_paths ~/bin ~/dotfiles/scripts

# bobthefish config
set -g theme_date_format "+%a %H:%M:%S"
set -g theme_display_vi no
set -g theme_display_git_ahead_verbose yes
set -g theme_display_vagrant yes
set -g theme_display_hg yes
set -g theme_display_cmd_duration yes
set -g theme_git_worktree_support yes
set -g theme_nerd_fonts yes
set -g theme_title_display_process yes
set -g theme_color_scheme zenburn
