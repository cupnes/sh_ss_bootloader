#!/bin/bash

# 引数で指定されたアドレスへ引数で指定されたファイルの内容を
# キャラクタデータ（4bits/px）として配置する。

set -ue

. include/common.sh

addr=$1
char_data_csv=$2

digits_counter=0
for c in $(tr '\n' ',' <$char_data_csv | tr ',' ' '); do
	case $digits_counter in
	0)
		val=$c
		digits_counter=$((digits_counter + 1))
		;;
	7)
		val="${val}$c"
		./poke.sh long $addr $val
		digits_counter=0
		addr=$(calc16_8 "${addr}+4")
		;;
	*)
		val="${val}$c"
		digits_counter=$((digits_counter + 1))
	esac
done
