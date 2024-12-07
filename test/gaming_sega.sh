#!/bin/bash

set -ue

rm -f stop

./exec.sh test_mcipd_mo_bit

# stop ファイルを置くと止まる
while [ ! -e stop ]; do
  t=$((RANDOM % 32768))
  v=$(bc <<< "obase=16;32768 + $t")
  ./poke.sh word 25F00010 $v
  sleep 0.1
done
