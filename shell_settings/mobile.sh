function ca() {
    directory=`cat ~/Documents/git/mobile/shell_settings/path.txt | fzf`
    directory=${directory/\~/$HOME} # チルダをホームディレクトリに置換
    cd "${directory}"
}

alias upsh="source ~/.zshrc"

DAEMON_PATH=~/Documents/git/mobile/pokemon/sleep/daemon
TODO_PATH=~/Documents/git/todo

alias d="bash ${DAEMON_PATH}/daemon.sh"
alias s="bash ${DAEMON_PATH}/mark.sh ; bash ${DAEMON_PATH}/state.sh"
alias p="bash ~/Documents/git/mobile/pokemon/tcg/12hourCheck.bash"

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

