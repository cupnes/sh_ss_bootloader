#!/bin/bash

# CSVで指定されたタイルを指定されたタイル座標へ配置する。

# 例：'A'をタイル座標(0, 1)へ配置する
# test/put_tile.sh test/char_data/A.csv 1400 0 1

set -ue

# CSV形式のタイルデータ
# （これをセガサターン上のピクセルフォーマットへ変換し
# 　キャラクタデータとして配置する）
# 例：test/char_data/A.csv
CHAR_DATA_CSV=$1

# キャラクタデータ配置先のVRAM内のオフセット
# （アドレスから上位16ビットの"{0,2}5Ex"を除いた値）
# 例：1400
CHAR_DATA_OFS=$2

# タイル座標
# （10進数で指定）
PUT_TILE_COORD_X_DEC=$3
PUT_TILE_COORD_Y_DEC=$4

# キャラクタデータを配置するアドレス
CHAR_DATA_ADDR=25E0$CHAR_DATA_OFS

# カラーRAM内のパレットのオフセット
# （先頭に定義されているものを使う）
PALETTE_OFS=0

# パターンネームデータ領域の先頭アドレス
PATTERN_NAME_DATA_BASE=25E06000

test/put_char_data.sh $CHAR_DATA_ADDR $CHAR_DATA_CSV
pattern_name_data_addr=$(test/calc_pattern_name_data_addr.sh $PATTERN_NAME_DATA_BASE $PUT_TILE_COORD_X_DEC $PUT_TILE_COORD_Y_DEC)
pattern_name_data=$(test/calc_pattern_name_data.sh $PALETTE_OFS $CHAR_DATA_OFS)
./poke.sh word $pattern_name_data_addr $pattern_name_data
