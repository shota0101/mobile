#!/bin/bash

# macOS (BSD) と Linux (GNU) 両方に対応した日付フォーマット関数
if date -j >/dev/null 2>&1; then
    # macOS (BSD date)
    format_date() {
        date -j -f %s "$1" "$2"
    }
else
    # Linux (GNU date)
    format_date() {
        date -d @"$1" "$2"
    }
fi

# stat コマンドでファイルの最終更新時刻を取得（macOS と Linux 両対応）
get_file_mtime() {
    local file="$1"
    if stat -f %m "$file" >/dev/null 2>&1; then
        # macOS (BSD stat)
        stat -f %m "$file"
    else
        # Linux (GNU stat)
        stat -c %Y "$file"
    fi
}
