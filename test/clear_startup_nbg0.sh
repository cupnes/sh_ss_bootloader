#!/bin/bash

# 起動時のNBG0のパターンネームデータをクリアする。

set -ue

while read delete_area_first delete_area_last; do
	./clear_range.sh word "25e0$delete_area_first" "25e0$delete_area_last"
done <<EOF
6498 64ba
6518 653a
6598 65ba
6618 663a
6698 66ba
6718 673a
6988 69c8
6a08 6a48
6b14 6b3c
6b94 6bbc
EOF
