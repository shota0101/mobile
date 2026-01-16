#!/bin/bash

# 入力を受け取る
read -p "hour を入力してください: " hour
read -p "minute を入力してください: " minute

# 分に変換
time=$((hour * 60 + minute))
max=$((8 * 60 + 30))

# 回復量（小数点以下切り捨て）
recovery=$((100 * time / max))
recovery_bonus=$((recovery * 114 / 100)) # 元気回復ボーナスを考慮
recovery_nature_downward=$((recovery * 88 / 100)) # 性格補正後（0.88倍 → 88/100 で整数演算）
recovery_nature_downward_bonus=$((recovery_nature_downward * 114 / 100)) # 性格補正後（0.88倍 → 88/100 で整数演算）

echo "$((100 - recovery)) 補正なしで全回復"
echo "$((100 - recovery_bonus)) 元気回復ボーナス"
echo "$((100 - recovery_nature_downward)) 性格下降補正"
echo "$((100 - recovery_nature_downward_bonus)) 性格下降補正と元気回復ボーナス"

