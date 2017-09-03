# works except for git-commit style on termux
#set -x MICRO_TRUECOLOR 1

set -x CONFIG_SHELL $PREFIX/bin/sh 

# the fishy way of updating PATH
set -U fish_user_paths ~/scripts

function fish_prompt
	python2 ~/proj/_external/powerline-shell/powerline-shell.py $status --shell bare ^/dev/null
end

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

