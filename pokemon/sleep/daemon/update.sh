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

cd ~/Documents/git/mobile/pokemon/sleep/interval/result
no=`ls | fzf`
cd $no
txtFile=`ls | fzf`
intervalWithDecimalPoint=`cat $txtFile | tail -n 20 | fzf | awk '{print $2}'`
interval=`echo $intervalWithDecimalPoint | awk '{print int($1)}'`
echo $interval > ~/Documents/git/mobile/pokemon/sleep/daemon/config/${no}.txt

