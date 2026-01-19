#!/bin/bash

# 入力を受け取る
read -p "チケット回復までの残り時間を入力してください: " hour
read -p "チケット回復までの残り分数を入力してください: " minute

leftoverTime=$((hour * 60 + minute))
currentTime=$((360 - leftoverTime / 2)) # leftoverTime / 2 の小数点以下は切り捨て
echo $leftoverTime
echo $currentTime

