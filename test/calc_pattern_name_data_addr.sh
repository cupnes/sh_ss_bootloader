#!/bin/bash

# 指定されたパターンネームデータベースアドレスとタイル座標
# に対応するパターンネームデータのアドレスを出力する。

set -ue

. include/common.sh

# パターンネームデータサイズは2バイトにのみ対応
PATTERN_NAME_DATA_SIZE=2
# 1行のバイト数（16進数）
LINE_BYTES=80

pattern_name_data_base=$1
tile_coord_x_dec=$2
tile_coord_y_dec=$3

tile_coord_x=$(to16 $tile_coord_x_dec)
tile_coord_y=$(to16 $tile_coord_y_dec)

pattern_name_data_addr=$(calc16_8 "${pattern_name_data_base}+(${LINE_BYTES}*${tile_coord_y})+(${PATTERN_NAME_DATA_SIZE}*${tile_coord_x})")
echo $pattern_name_data_addr
