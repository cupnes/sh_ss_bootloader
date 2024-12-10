#!/bin/bash

# 起動時のNBG0のパターンネームデータをクリアする。

set -ue

while read delete_area_first delete_area_last; do
	./clear_range.sh long "25e0$delete_area_first" "25e0$delete_area_last"
done <<EOF
6498 64b8
6518 6538
6598 65b8
6618 6638
6698 66b8
6718 6738
6988 69c8
6a08 6a48
6b14 6b3c
6b94 6bbc
EOF
