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

function classifyLandscapeImages {
    local new_files="$1"
    local source_dir="$2"
    
    if [ -z "$new_files" ]; then
        echo "新しいファイルはありません"
        return
    fi
    
    # imagemagickの確認
    if ! command -v identify &> /dev/null; then
        echo "⚠️  ImageMagick (identify) がインストールされていません。横長画像の分類をスキップします"
        return
    fi
    
    echo "↓----- Classifying landscape images -----↓"
    while IFS= read -r file; do
        [ -z "$file" ] && continue
        
        file_path="${source_dir}${file}"
        
        # ファイルが存在することを確認
        if [ ! -f "$file_path" ]; then
            continue
        fi
        
        # 画像の横幅と縦幅を取得
        dimensions=$(identify -format "%wx%h" "$file_path" 2>/dev/null)
        if [ -z "$dimensions" ]; then
            continue
        fi
        
        width=$(echo "$dimensions" | cut -d'x' -f1)
        height=$(echo "$dimensions" | cut -d'x' -f2)
        
        # 横長（width > height）であれば landscape フォルダに移動
        if [ "$width" -gt "$height" ]; then
            mkdir -p ~/storage/pictures/master/landscape
            # スペースを含むファイル名に対応
            mv "$file_path" ~/storage/pictures/master/landscape/"$file"
            echo "  ✓ ${file} (${width}x${height}) を landscape に移動"
        fi
    done <<< "$new_files"
    echo "↑----- Classifying landscape images -----↑"
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

echo "↓----- Checking files before -----↓"
ls ~/storage/pictures/master/cross/ > ~/storage/pictures/master/checkCrossBefore.txt
echo "✓ Saved to checkCrossBefore.txt"
echo "↑----- Checking files before -----↑"

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

echo "↓----- Checking files after -----↓"
ls ~/storage/pictures/master/cross/ > ~/storage/pictures/master/checkCrossAfter.txt 2>/dev/null || echo "" > ~/storage/pictures/master/checkCrossAfter.txt
echo "✓ Saved to checkCrossAfter.txt"
echo "↑----- Checking files after -----↑"

# 新しく追加されたファイルを抽出
new_files=$(diff ~/storage/pictures/master/checkCrossBefore.txt ~/storage/pictures/master/checkCrossAfter.txt | grep "^>" | sed 's/^> //')

classifyLandscapeImages "$new_files" ~/storage/pictures/master/cross/

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

