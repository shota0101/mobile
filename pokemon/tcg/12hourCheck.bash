#!/bin/bash

# 共通関数を読み込み
source "$(dirname "$0")/common.bash"

# 現在時刻を取得（秒単位）
current_time=$(date +%s)

# 12時間前の時刻（秒単位）
twelve_hours_ago=$((current_time - 43200))

# state/*.txtファイルを確認し、12時間以上経過しているものをリストアップ
files_list=""
for file in state/*; do
    # ファイルが存在しない場合はスキップ
    [ -e "$file" ] || continue
    
    # ファイルの最終更新時刻を取得
    file_time=$(get_file_mtime "$file")
    
    # 12時間以上経過しているか確認
    if [ "$file_time" -le "$twelve_hours_ago" ]; then
        # ファイル名（拡張子無し）を取得
        basename=$(basename "$file" .txt)
        # 最終更新時刻をフォーマット
        formatted_time=$(format_date "$file_time" '+%m月%d日 %H時%M分')
        # リストに追加
        files_list="${files_list}${basename} ${formatted_time}|${file}\n"
    fi
done

# 対象ファイルがない場合は終了
if [ -z "$files_list" ]; then
    echo "12時間以上経過しているファイルはありません"
    exit 0
fi

# fzfで選択
selected=$(printf "%b" "$files_list" | fzf --delimiter="|" --with-nth=1 | cut -d'|' -f2)

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
