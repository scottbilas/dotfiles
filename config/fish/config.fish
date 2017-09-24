# ensure our shell is us, and not bash or whatev somehow
set -x SHELL (which fish)

# termux support
set -q PREFIX; or set -x PREFIX ""

# the fishy way of updating PATH
set -U fish_user_paths ~/bin ~/dotfiles/scripts


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
#set -x MICRO_TRUECOLOR 1  # almost works.. except for git-commit style (at least on termux)

set -x ELINKS_CONFDIR ~/.config/elinks
set -x TIGRC_USER ~/.config/tig/config   # tig 2.2 supports XDG standard, eventually won't need this

# bobthefish config
set -g theme_display_git_untracked yes
set -g theme_display_git_ahead_verbose yes
set -g theme_git_worktree_support no
set -g theme_display_vagrant yes
set -g theme_display_docker_machine yes
set -g theme_display_hg yes
set -g theme_display_virtualenv yes
set -g theme_display_ruby no
set -g theme_display_user yes
set -g theme_display_vi no
set -g theme_display_date yes
set -g theme_display_cmd_duration yes
set -g theme_title_display_process yes
set -g theme_title_display_path no
set -g theme_title_display_user yes
set -g theme_title_use_abbreviated_path no
set -g theme_date_format "+%H:%M"
set -g theme_avoid_ambiguous_glyphs yes
set -g theme_powerline_fonts yes
set -g theme_nerd_fonts yes
set -g theme_show_exit_status yes
set -g default_user scott
set -g theme_color_scheme zenburn
set -g fish_prompt_pwd_dir_length 1
set -g theme_project_dir_length 0
set -g theme_newline_cursor yes

# dircolors
eval (dircolors -c ~/dotfiles/repos/dircolors-solarized/dircolors.256dark)

# TODO alias mc='. /usr/libexec/mc/mc-wrapper.sh'
