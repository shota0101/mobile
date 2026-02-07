function ca() {
    directory=`cat ~/Documents/git/mobile/shell_settings/path.txt | fzf`
    directory=${directory/\~/$HOME} # チルダをホームディレクトリに置換
    cd "${directory}"
}

alias upsh="source ~/.zshrc"

DAEMON_PATH=~/Documents/git/mobile/pokemon/sleep/daemon
TCG_PATH=~/Documents/git/mobile/pokemon/tcg
TODO_PATH=~/Documents/git/todo

alias d="bash ${DAEMON_PATH}/daemon.sh"
alias s="bash ${DAEMON_PATH}/mark.sh ; bash ${DAEMON_PATH}/state.sh ; bash ${TCG_PATH}/listExpiredFiles.bash"
alias 12="bash ${TCG_PATH}/12hourCheck.bash"

function r() {
    cd $DAEMON_PATH
    bash reflect.sh
}

function t() {
    cd $TODO_PATH
    bash list.sh
}

function m() {
    cd $TODO_PATH
    bash mark_due.sh
}

bash Documents/git/mobile/pokemon/sleep/daemon/state.sh
bash Documents/git/mobile/pokemon/tcg/listExpiredFiles.bash

