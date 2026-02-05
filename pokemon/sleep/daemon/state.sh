#!/usr/bin/env bash

# bash で実行されているかチェックし、そうでなければ bash で再実行する
if [ -z "${BASH_VERSION:-}" ]; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "${0}" "$@"
  else
    echo "bash is required to run this script" >&2
    exit 1
  fi
fi

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"

# TODO 共通化
get_mtime() {
	# ポータブルな mtime 取得: BSD の stat(-f %m) が使える場合はそれを優先し、なければ GNU stat(-c %Y) を使う
	local file="$1"
	if stat -f %m "$file" >/dev/null 2>&1; then
		stat -f %m "$file"
	else
		stat -c %Y "$file"
	fi
}

format_time() {
	# epoch秒から HH:MM を返す（macOS/BSD と GNU date に対応）
	local epoch=$1
	if date -r "$epoch" '+%H:%M' >/dev/null 2>&1; then
		date -r "$epoch" '+%H:%M'
	elif date -d @"$epoch" '+%H:%M' >/dev/null 2>&1; then
		date -d @"$epoch" '+%H:%M'
	else
		echo "??:??"
	fi
}

if [ ! -d "$CONFIG_DIR" ]; then
	echo "config directory not found: $CONFIG_DIR" >&2
	exit 1
fi

# 一時ファイルを作成
tmpfile=$(mktemp)
trap "rm -f $tmpfile" EXIT

# 各 .txt ファイルの due 時刻を取得し、一時ファイルに記録
shopt -s nullglob
for txt in "$CONFIG_DIR"/*.txt; do
	base="$(basename "$txt" .txt)"

	# .txt の1行目から分数（minutes）を読み取る
	minutes_raw=$(awk 'NR==1{print $1}' "$txt" 2>/dev/null || true)
	minutes="${minutes_raw//[^0-9]/}"
	if [ -z "$minutes" ]; then
		# 無効または空の場合はスキップ
		continue
	fi

	# .txt ファイルの最終更新時刻（mtime）を最終マーク時刻として使用
	mtime=$(get_mtime "$txt")
	# interval_sec は考慮しない
	due=$(( mtime + minutes * 60 ))
	
	# due|base の形式で一時ファイルに記録
	echo "$due|$base" >> "$tmpfile"
done

# due を昇順でソート
sorted_records=$(sort -n "$tmpfile" 2>/dev/null)

# 昇順で表示
now_epoch=$(date +%s)
while IFS='|' read -r due base; do
	due_time=$(format_time "$due")
	
	# 現在時刻との差分を計算
	if [ "$due" -le "$now_epoch" ]; then
		overdue_sec=$(( now_epoch - due ))
		overdue_min=$(( (overdue_sec + 59) / 60 ))
		status="[${overdue_min}分経過]"
	else
		remaining_sec=$(( due - now_epoch ))
		remaining_min=$(( (remaining_sec + 59) / 60 ))
		status="[あと${remaining_min}分]"
	fi
	
	printf "%s %s %s\n" "$base" "$due_time" "$status"
done <<< "$sorted_records"

exit 0
