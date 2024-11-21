#!/bin/bash

set -uex

usage() {
	echo 'Usage:' 1>&2
	echo -e "\t$0 TILE_X TILE_Y" 1>&2
	echo -e "\t$0 -h" 1>&2
}

while getopts h option; do
	case $option in
	h)
		usage
		exit 0
		;;
	*)
		usage
		exit 1
	esac
done
shift $((OPTIND - 1))
if [ $# -ne 2 ]; then
	usage
	exit 1
fi

TILE_X=$1
TILE_Y=$2

./exec.sh test_mcipd_mo_bit

# VRSIZE(25f80006h)へ0x0000を設定
./poke.sh word 25f80006 0000

# BGON(25f80020h)でNBG0を非表示にする
./poke.sh word 25f80020 0000

# コマンドテーブルの毎フレーム設定系の直後のCMDCTRL(25c00060h)のENDビットを設定
# し、スプライトを非表示にする
./poke.sh word 25c00060 8000

# CHCTLA(25f80028h)へ設定しNBG0をタイル形式へ変更する
# - b[6:4] = N0CHCN[2:0] = 0b001 (256色、パレット形式)
# - b1 = N0BMEN = 0 (タイル形式)
# - b0 = N0CHSZ = 0 (キャラクタパターンサイズ = 横1タイル×縦1タイル)
./poke.sh word 25f80028 0010

# PNCN0(25f80030h)を設定する
# - b15 = N0PNB = 1 (パターンネームデータサイズ：1ワード)
# - b14 = N0CNSM = 0 (パターンネームデータ中のキャラクタナンバー：10ビット)
# - b9 = N0SPR = 0
# - b8 = N0SCC = 0
# - b[7:5] = N0SPLT[6:4] = 0b000
# - b[4:0] = N0SCN[4:0] = 0b01100
# → 800c
./poke.sh word 25f80030 800c

# SFPRMD(25f800ea)へ0x0000を設定する
./poke.sh word 25f800ea 0000

# 25e61040hへ1タイル分のピクセルデータを配置
base=25E61040
adr=$base
cnt=$((64 / 4))
for ((i = 0; i < $cnt; i++)); do
	./poke.sh long $adr 11111111
	adr=$(bc <<< "obase=16;ibase=16;$adr + 4")
done

# 25f00402hへ赤色の色情報(801fh)を書く
./poke.sh word 25f00402 801f

# 25e76000hへパターンネームデータ2082hを書く
adr=25E76000
for ((i = 0; i < 100; i++)); do
	./poke.sh word $adr 2082
	adr=$(bc <<< "obase=16;ibase=16;$adr + 2")
done

# (マップオフセットレジスタ + マップレジスタA-D)へ00076000hを設定する
# マップオフセットレジスタ = 0
# MPOFN(25f8003ch)
# - b[2:0] = N0MP[8:6] = 0b000
./poke.sh word 25f8003c 0000
# マップレジスタA-D = 0x3b
# MPABN0(25f80040h)
# - b[13:8] = N0MPB[5:0] = 0x3b
# - b[5:0] = N0MPA[5:0] = 0x3b
./poke.sh word 25f80040 3b3b
# MPCDN0(25f80042h)
# - b[13:8] = N0MPD[5:0] = 0x3b
# - b[5:0] = N0MPC[5:0] = 0x3b
./poke.sh word 25f80042 3b3b

# BGON(25f80020h)でNBG0を表示する
./poke.sh word 25f80020 0001
