# Defined in /tmp/fish.szWuQD/mc.fish @ line 1
function mc
	set SHELL_PID %self
    set MC_PWD_FILE "$TMPDIR/mc-$USER/mc.pwd.$SHELL_PID"

    $PREFIX/usr/bin/mc -P $MC_PWD_FILE $argv

    if test -r $MC_PWD_FILE

        set MC_PWD (cat $MC_PWD_FILE)
        if test -n "$MC_PWD"
            and test -d "$MC_PWD"
            cd (cat $MC_PWD_FILE)
        end

        rm $MC_PWD_FILE
    end
end
