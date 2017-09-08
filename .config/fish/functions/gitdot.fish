# Defined in - @ line 2
function gitdot
	git --git-dir=$HOME/.dotfiles/.git_/ --work-tree=$HOME $argv
end
