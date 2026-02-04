function ca() {
    directory=`cat ~/Documents/git/mobile/shell_settings/path.txt | fzf`
    directory=${directory/\~/$HOME} # チルダをホームディレクトリに置換
    cd "${directory}"
}

alias upsh="source ~/.zshrc"

DAEMON_PATH=~/Documents/git/mobile/pokemon/sleep/daemon
TODO_PATH=~/Documents/git/todo

function d() {
    cd $DAEMON_PATH
    bash daemon.sh
}

function s() {
    cd $DAEMON_PATH
    bash state.sh
}

function p() {
    cd $DAEMON_PATH
    bash mark.sh
    bash state.sh
}

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

