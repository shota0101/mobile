#!/bin/bash

# 入力を受け取る
read -p "hour を入力してください: " hour
read -p "minute を入力してください: " minute

# 分に変換
time=$((hour * 60 + minute))
max=$((8 * 60 + 30))

# 回復量（小数点以下切り捨て）
recovery=$((100 * time / max))

# 性格補正後（0.88倍 → 88/100 で整数演算）
recovery_nature_downward=$((recovery * 88 / 100))

# 出力
echo "回復量：$recovery"
echo "回復量：$recovery_nature_downward （性格下降補正）"
echo "元気が $((100 - recovery)) なら全回復"
echo "元気が $((100 - recovery_nature_downward)) なら性格下降補正でも全回復"

