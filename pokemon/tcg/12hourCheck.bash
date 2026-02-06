#!/bin/bash

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 共通関数を読み込み
source "$SCRIPT_DIR/common.bash"

# 現在時刻を取得（秒単位）
current_time=$(date +%s)

# 12時間以上経過しているファイルを取得（--rawでパイプ用形式）
files_list=$(bash "$SCRIPT_DIR/listExpiredFiles.bash" --raw)

# 対象ファイルがない場合は終了
if [ -z "$files_list" ]; then
    echo "12時間以上経過しているファイルはありません"
    exit 0
fi

# fzfで選択
selected=$(echo "$files_list" | fzf --delimiter="|" --with-nth=1 | cut -d'|' -f2)

# 選択されなかった場合は終了
if [ -z "$selected" ]; then
    echo "ファイルが選択されませんでした"
    exit 0
fi

# 選択されたファイルの最終更新時刻を取得
file_time=$(get_file_mtime "$selected")

# 24時間以上経過しているか確認
twenty_four_hours_ago=$((current_time - 86400))

if [ "$file_time" -le "$twenty_four_hours_ago" ]; then
    # 24時間以上経過している場合は、現在時刻-12時間でtouch
    new_time=$((current_time - 43200))
    new_timestamp=$(format_date $new_time +%Y%m%d%H%M.%S)
    touch -t "$new_timestamp" "$selected"
    echo "ファイル '$selected' を現在時刻-12時間で更新しました"
    formatted_time=$(format_date $new_time '+%Y-%m-%d %H:%M:%S')
    echo "新しいタイムスタンプ: $formatted_time"
else
    # 12時間進める
    new_time=$((file_time + 43200))
    new_timestamp=$(format_date $new_time +%Y%m%d%H%M.%S)
    touch -t "$new_timestamp" "$selected"
    echo "ファイル '$selected' を12時間進めました"
    formatted_time=$(format_date $new_time '+%Y-%m-%d %H:%M:%S')
    echo "新しいタイムスタンプ: $formatted_time"
fi
