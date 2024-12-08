#!/bin/bash

# 起動時のNBG0のパターンネームデータをクリアする。

set -ue

delete_area_1_first=25e06498
delete_area_1_last=25e0673a
delete_area_2_first=25e06988
delete_area_2_last=25e06bbc

./clear_range.sh word $delete_area_1_first $delete_area_1_last
./clear_range.sh word $delete_area_2_first $delete_area_2_last
