#!/bin/sh

file="estimatedValueTable.tsv"

awk -F'\t' '{print}' "$file" \
| fzf --prompt="ポケモンを選択 > " \
| awk -F'\t' '{print $3}'

