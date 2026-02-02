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

# 共通ユーティリティ関数を読み込む
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# config/ 以下の .txt ファイルをチェックして、設定された間隔で通知を行う。
# - 各 .txt の1行目には分数（minutes）だけが記載される想定。
# - 通知の「最終時刻」は .txt ファイル自身の更新時刻（`touch`）で管理する。`mark.sh` を使って該当の .txt を touch して通知済みにするフローを想定する。

CONFIG_DIR="$SCRIPT_DIR/config"

notify_msg() {
	local file_name="$1"
	local overdue_min="$2"
	local msg="${overdue_min}分経過"

	if [ "${DEBUG:-0}" != "0" ]; then
		>&2 echo "notify: [$file_name] $msg"
	fi

	echo "$file_name : $msg"
	
	if command -v termux-notification >/dev/null 2>&1; then
		termux-notification -t "$file_name" -c "$msg"
	fi
}

get_mtime() {
	# ポータブルな mtime 取得: BSD の stat(-f %m) が使える場合はそれを優先し、なければ GNU stat(-c %Y) を使う
	local file="$1"
	if stat -f %m "$file" >/dev/null 2>&1; then
		stat -f %m "$file"
	else
		stat -c %Y "$file"
	fi
}

if [ ! -d "$CONFIG_DIR" ]; then
	echo "config directory not found: $CONFIG_DIR" >&2
	exit 1
fi

# interval-sec.txt から間隔を読み取る
interval_sec=$(read_interval_sec)

now_epoch=$(date +%s)

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

	# .txt ファイルの最終更新時刻（mtime）を最終マーク時刻として使用する。mark.sh を使って該当の .txt を touch して通知済みにするフローを想定する。
	mtime=$(get_mtime "$txt")
	due=$(( mtime + minutes * 60 - interval_sec ))
	if [ "$due" -le "$now_epoch" ]; then
		# 経過秒数を計算（現在時刻 - 予定時刻）
		overdue_sec=$(( now_epoch - due ))
		if [ "$overdue_sec" -lt 0 ]; then
			overdue_sec=0
		fi
		# 秒を分に変換する際、シェルの整数除算は切り捨てになるため切り上げを行う。
		# 切り上げは (秒数 + 59) / 60 とすることで実現する（1〜60秒は1分として扱う）。
		overdue_min=$(( (overdue_sec + 59) / 60 ))
		if [ "$overdue_min" -le 0 ]; then
			overdue_min=0
		fi
		notify_msg "$base" "$overdue_min"
	fi
done

exit 0
