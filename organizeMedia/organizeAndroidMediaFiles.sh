#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"

function collectPhotos {
    echo "↓----- ${src/$HOME/\~} -----↓"
    bash "${SCRIPT_DIR}"renameImages.sh "$src" "$service"
    
    if ls "${src}"/*.jpg >/dev/null 2>&1; then
	mv "${src}"/*.jpg "$dst"
    fi
    
    if ls "${src}"/*.png >/dev/null 2>&1; then
	mv "${src}"/*.png "$dst"
    fi
    
    if ls "${src}"/*.gif >/dev/null 2>&1; then
	mv "${src}"/*.gif "$dst"
    fi
    
    if ls "${src}"/*.mp4 >/dev/null 2>&1; then
	mv "${src}"/*.mp4 "$dst"
    fi
    
    ls "$src"
    echo "↑----- ${src/$HOME/\~} -----↑"
}

dst=~/storage/pictures/life/

service=whats-app
src=~/storage/pictures/WhatsApp
collectPhotos

service=we-chat
src=~/storage/pictures/WeChat
collectPhotos

service=line
src=~/storage/pictures/LINE
collectPhotos
src=~/storage/movies/LINE
collectPhotos

dst=~/storage/pictures/master/cross/

service=pixiv
src=~/storage/pictures/pixiv
collectPhotos

service=pinterest
src=~/storage/pictures/100PINT/Pins
collectPhotos

echo "↓----- twitter -----↓"
sh "${SCRIPT_DIR}"renameTwitterImages.sh $dst
echo "↑----- twitter -----↑"

echo "TODO: LINEのデータの名前変換とバックアップ処理"
echo "↓----- ~/storage/pictures/LINE -----↓"
if ls ~/storage/pictures/LINE/* 2>/dev/null; then
    :
else
    echo "ファイルは存在しません"
fi
echo "↑----- ~/storage/pictures/LINE -----↑"

echo "↓----- ~/storage/movies/LINE -----↓"
if ls ~/storage/movies/LINE/* 2>/dev/null; then
    :
else
    echo "ファイルは存在しません"
fi
echo "↑----- ~/storage/movies/LINE -----↑"

echo ""
echo "↓----- Scanning media files -----↓"
termux-media-scan ~/storage/pictures/
termux-media-scan ~/storage/movies/
echo "↑----- Scanning complete -----↑"

