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

if [ ! -d "$CONFIG_DIR" ]; then
  echo "config directory not found: $CONFIG_DIR" >&2
  exit 1
fi

shopt -s nullglob 2>/dev/null || true
files=("$CONFIG_DIR"/*.txt)
if [ "${#files[@]}" -eq 0 ]; then
  echo "no .txt files under $CONFIG_DIR"
  exit 0
fi

if command -v fzf >/dev/null 2>&1; then
  # ベース名の一覧を fzf に渡して選択させる
  selected=$(printf '%s\n' "${files[@]##*/}" | fzf --prompt="select config .txt: ")
  if [ -z "${selected:-}" ]; then
    echo "no selection"
    exit 1
  fi
  target="$CONFIG_DIR/$selected"
  touch "$target"
  echo "touched: $target"
else
  echo "fzf not found; available files:"
  printf '%s\n' "${files[@]}"
fi
