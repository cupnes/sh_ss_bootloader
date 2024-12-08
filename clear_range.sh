#!/bin/bash

set -ue

. include/common.sh

access_width=$1
addr_first=$2
addr_last=$3
# addr_lastにはaccess_width単位の最終要素の先頭アドレスを指定する事
# 例えば、0x25e06498から0x25e06499までの2バイトをword単位でクリアしたい場合、
# addr_lastに25e06498を指定する。

access_width_bytes=$(access_width_to_bytes $access_width)
addr_out_of_range=$(calc16_8 "${addr_last}+${access_width_bytes}")
addr_out_of_range_dec=$(to10 $addr_out_of_range)

addr=$addr_first
addr_dec=$(to10 $addr)
while [ $addr_dec -lt $addr_out_of_range_dec ]; do
	./poke.sh $access_width $addr $(extend_digit 0 $(access_width_to_digits $access_width))
	addr=$(calc16_8 "${addr}+${access_width_bytes}")
	addr_dec=$(to10 $addr)
done
