#!/system/bin/sh
# adbではbashは使えないからshを利用
set -eu

# 第一引数チェック
if [ "$#" -lt 1 ]; then
  echo "Error: 第一引数に移動先のパスを指定してね" >&2
  exit 1
fi

DEST_DIR="$1"

# 末尾に / が無ければ追加
case "$DEST_DIR" in
  */) ;;
  *) DEST_DIR="${DEST_DIR}/" ;;
esac

cd ~/storage/pictures/Twitter
for file in ????????_??????.jpg; do
  [ -e "$file" ] || continue

  yyyy=$(echo "$file" | cut -c1-4)
  mm=$(echo "$file" | cut -c5-6)
  dd=$(echo "$file" | cut -c7-8)
  hh=$(echo "$file" | cut -c10-11)
  mi=$(echo "$file" | cut -c12-13)
  ss=$(echo "$file" | cut -c14-15)

  newname="${yyyy}-${mm}-${dd}_${hh}-${mi}-${ss}_twitter.jpg"
  echo $newname

  mv "$file" "${DEST_DIR}$newname"
done

