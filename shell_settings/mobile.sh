function ca() {
    directory=`cat ~/Documents/git/mobile/shell_settings/path.txt | fzf`
    directory=${directory/\~/$HOME} # チルダをホームディレクトリに置換
    cd "${directory}"
}

alias upsh="source ~/.zshrc"

DAEMON_PATH=~/Documents/git/mobile/pokemon/sleep/daemon

function d() {
    cd $DAEMON_PATH
    bash daemon.sh
}

function m() {
    cd $DAEMON_PATH
    bash mark.sh
    bash state.sh
}

function r() {
    cd $DAEMON_PATH
    bash reflect.sh
}

