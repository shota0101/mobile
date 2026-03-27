function j() {
    directory=`cat ~/Documents/git/mobile/shell_settings/path.txt | fzf`
    directory=${directory/\~/$HOME} # チルダをホームディレクトリに置換
    cd "${directory}"
}

LOCAL_COMMAND_LIST=~/Documents/git/mobile/shell_settings/terminal-mobile.sh
tt() {
    cat \
	$LOCAL_COMMAND_LIST \
	| fzf | tr -d '\n' | pbcopy
}

alias m="bash ~/Documents/git/todo/markAsDone.sh"

DAEMON_PATH=~/Documents/git/mobile/pokemon/sleep/daemon
function r() {
    cd $DAEMON_PATH
    bash reflect.sh
}

function h() {
    cd ~/Documents/git/household-accounts/
    bash run.sh
}

