#!/bin/bash

# 共通関数を読み込み
source "$(dirname "$0")/common.bash"

read -p "作成するファイル名を入力してください: " filename
read -p "12時間経過まで何時間ですか？: " hours
read -p "12時間経過まで何分ですか？: " minutes

# 現在時刻を取得
current_time=$(date +%s)

# 12時間経過する時刻を計算（秒単位）
time_until_12hours=$((hours * 3600 + minutes * 60))
target_time=$((current_time + time_until_12hours))

# 12時間前の時刻を計算（12時間 = 43200秒）
file_time=$((target_time - 43200))

# stateディレクトリが存在しない場合は作成
mkdir -p state

# 指定した時刻でファイルを作成
file_timestamp=$(format_date "$file_time" +%Y%m%d%H%M.%S)
touch -t "$file_timestamp" "state/${filename}"

echo "ファイル 'state/${filename}' を作成しました"
formatted_time=$(format_date "$file_time" '+%Y-%m-%d %H:%M:%S')
echo "ファイルのタイムスタンプ: $formatted_time"

