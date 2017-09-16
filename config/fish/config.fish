# works except for git-commit style on termux
#set -x MICRO_TRUECOLOR 1

set -x CONFIG_SHELL $PREFIX/bin/sh 
set -x EDITOR $PREFIX/bin/micro
set -x ELINKS_CONFDIR ~/.config/elinks

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

# the fishy way of updating PATH
set -U fish_user_paths ~/bin ~/dotfiles/scripts

function mc
     set SHELL_PID %self
     set MC_PWD_FILE "$TMPDIR/mc-$USER/mc.pwd.$SHELL_PID"

     ~/usr/bin/mc -P $MC_PWD_FILE $argv

     if test -r $MC_PWD_FILE

         set MC_PWD (cat $MC_PWD_FILE)
         if test -n "$MC_PWD"
             and test -d "$MC_PWD"
             cd (cat $MC_PWD_FILE)
         end

         rm $MC_PWD_FILE
     end
end

