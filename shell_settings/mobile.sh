function ca() {
    directory=`cat ~/Documents/git/box/memo/path.txt | fzf`
    directory=${directory/\~/$HOME} # チルダをホームディレクトリに置換
    cd "${directory}"
}
