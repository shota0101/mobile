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

NOTIFY_SH="$SCRIPT_DIR/notify.sh"

if [ ! -x "$NOTIFY_SH" ]; then
	# 実行権が無くても実行を試みるが、スクリプト自体が存在しない場合は警告して終了する
	if [ ! -f "$NOTIFY_SH" ]; then
		echo "notify script not found: $NOTIFY_SH" >&2
		exit 1
	fi
fi

while true; do
	"$NOTIFY_SH" || true
	
	interval_sec=$(read_interval_sec)
	sleep "$interval_sec"
done

exit 0
