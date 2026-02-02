#!/usr/bin/env bash

# 共通ユーティリティ関数

# interval-sec.txt から間隔秒数を読み取る
# 使用方法: interval_sec=$(read_interval_sec)
read_interval_sec() {
	local default_interval=300
	local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	local interval_file="$script_dir/interval-sec.txt"
	
	if [ -f "$interval_file" ]; then
		local interval=$(awk 'NR==1{print $1}' "$interval_file" 2>/dev/null || true)
		if [ -z "$interval" ] || ! [[ "$interval" =~ ^[0-9]+$ ]]; then
			echo "$default_interval"
		else
			echo "$interval"
		fi
	else
		echo "$default_interval"
	fi
}
