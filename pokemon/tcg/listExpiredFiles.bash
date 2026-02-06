#!/bin/bash

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 共通関数を読み込み
source "$SCRIPT_DIR/common.bash"

# オプション解析（--raw: パイプ用の内部形式で出力）
RAW_OUTPUT=false
if [ "$1" = "--raw" ]; then
    RAW_OUTPUT=true
fi

# 現在時刻を取得（秒単位）
current_time=$(date +%s)

# 12時間前の時刻（秒単位）
twelve_hours_ago=$((current_time - 43200))

# state/*ファイルを確認し、12時間以上経過しているものをリストアップ
for file in "$SCRIPT_DIR/state"/*; do
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
        # 出力
        if [ "$RAW_OUTPUT" = true ]; then
            echo "${basename} ${formatted_time}|${file}"
        else
            echo "${basename} ${formatted_time}"
        fi
    fi
done

