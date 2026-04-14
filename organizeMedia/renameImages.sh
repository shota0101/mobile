#!/bin/bash
set -euo pipefail

# --- 引数チェック ---
if (( $# < 2 || $# > 3 )); then
  echo "Usage: $0 <directory> <service|no-service> [keepCurrentName]"
  exit 1
fi

target_dir="$1"
service="$2"
keep_current_name="${3:-true}"

if [[ ! -d "$target_dir" ]]; then
  echo "Error: directory not found: $target_dir"
  exit 1
fi

if [[ "$keep_current_name" != "true" && "$keep_current_name" != "false" ]]; then
  echo "keepCurrentName must be true or false"
  exit 1
fi

# --- 環境判定 ---
OS="$(uname)"

if [[ "$OS" == "Darwin" ]]; then
  get_mtime() {
    stat -f "%Sm" -t "%Y-%m-%d_%H-%M-%S" "$1"
  }
else
  get_mtime() {
    stat -c %y "$1" \
      | sed -E 's/^([0-9-]+) ([0-9:]+).*/\1_\2/' \
      | tr ':' '-'
  }
fi

cd "$target_dir"

# --- 対象拡張子 ---
for file in *.jpg *.png *.gif *.mp4; do
  [[ -e "$file" ]] || continue

  filename="${file##*/}"

  # --- 20から始まるファイルはスキップ ---
  if [[ "$filename" == 20* ]]; then
    continue
  fi

  datetime="$(get_mtime "$file")"

  ext="${filename##*.}"
  base="${filename%.*}"

  parts=("$datetime")

  if [[ "$service" != "no-service" ]]; then
    parts+=("$service")
  fi

  if [[ "$keep_current_name" == "true" ]]; then
    parts+=("$base")
  fi

  newname="$(IFS=_; echo "${parts[*]}").${ext}"
  echo $newname

  # --- 衝突回避 ---
  if [[ -e "$newname" ]]; then
    i=1
    while [[ -e "${newname%.*}_$i.${ext}" ]]; do
      ((i++))
    done
    newname="${newname%.*}_$i.${ext}"
  fi

  mv "$file" "$newname"
done

