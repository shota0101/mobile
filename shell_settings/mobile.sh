j() {
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

# Wi-Fi接続状態を表示
print_wifi_status() {
    # termux-wifi-connectioninfoコマンドでWi-Fi接続状態を取得
    if ! command -v termux-wifi-connectioninfo &> /dev/null; then
        echo '❌termux-wifi-connectioninfoコマンド無し'
    fi

    local wifi_info
    wifi_info=$(termux-wifi-connectioninfo 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo '❌termux-wifi-connectioninfoコマンド実行エラー'
    fi

    # JSONからbssidとipを抽出して接続状態を判定
    local bssid
    local ip
    bssid=$(echo "$wifi_info" | grep -o '"bssid": *"[^"]*"' | cut -d'"' -f4)
    ip=$(echo "$wifi_info" | grep -o '"ip": *"[^"]*"' | cut -d'"' -f4)

    # bssidがnullでなく、ipが0.0.0.0でもない場合は接続されている
    if [ -n "$bssid" ] && [ "$bssid" != "null" ] && [ "$ip" != "0.0.0.0" ]; then
        echo '✅Wi-Fi接続確認完了'
	return
    fi

    echo '❌Wi-Fi接続確認できませんでした'
}

echo "p : Pokémon Sleep"
function p() {
    cd ~/Documents/git/mobile/pokemon/sleep/daemon
    bash reflect.sh
}

echo "r\t: rotation"
alias r="bash ~/Documents/git/rotation/rotation.sh"

echo "lt\t: log temperature"
alias lt="bash ~/Documents/git/temperature/log.bash"
echo "ss\t: sleep suggest"
alias ss="bash ~/Documents/git/temperature/search.bash"

echo "gpa\t: git pull all"
alias gall="bash ~/Documents/git/company/script/pull-all.sh"

echo "om\t: organize media"
alias media="bash ~/Documents/git/mobile/organizeMedia/organizeAndroidMediaFiles.sh"

echo "m\t: mark tasks as done"
alias m="bash ~/Documents/git/todo/markAsDone.sh"
bash ~/Documents/git/todo/listUnfinishedTasks.sh

print_wifi_status &

