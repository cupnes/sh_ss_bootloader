#!/bin/bash

# 関数のテンプレートを作成する
# - このリポジトリをクローンしたディレクトリ直下で実行すること
# - 指定された関数の定義を中身が空の状態で作成する
# - 作成する関数については、関数名(FUNC_NAME)と
#   定義箇所の1行目に書く説明文(FUNC_DESC)を指定する
# - funcs()内に関して、関数はBEFORE_FUNC_NAMEで指定された関数の直後に作成される
# - FUNC_NAMEとBEFORE_FUNC_NAMEで指定する関数名には接頭辞の"f_"を除いて指定する
# - -fでファイルを指定すると関数の定義をそのファイルの末尾へ追加する
#   - 指定がない場合、src/funcs.shの末尾へ追加する
#   - 関数定義の位置は適宜手動で修正すること

# set -uex
set -ue

usage() {
	echo 'Usage:' 1>&2
	echo -e "\t$0 [-f DEF_TO_FILE] BEFORE_FUNC_NAME FUNC_NAME FUNC_DESC" 1>&2
	echo -e "\t$0 -h" 1>&2
}

DEF_TO_FILE=src/funcs.sh
while getopts hf: option; do
	case $option in
	h)
		usage
		exit 0
		;;
	f)
		DEF_TO_FILE=${OPTARG}
		;;
	*)
		usage
		exit 1
	esac
done
shift $((OPTIND - 1))
if [ $# -ne 3 ]; then
	usage
	exit 1
fi

BEFORE_FUNC_NAME=$1
FUNC_NAME=$2
FUNC_DESC=$3

TAB="$(printf '\\\011')"

# 既に関数が追加済みだったら基本的に何もせず終了する
SKIP='false'
DUMP_FUNC_FOR_FUNCS="${TAB}cat src\/f_${FUNC_NAME}.o"
if grep -q "^$DUMP_FUNC_FOR_FUNCS" src/funcs.sh; then
	echo "f_${FUNC_NAME}() is already exists." 1>&2

	if [ "$DEF_TO_FILE" != 'src/funcs.sh' ] && ! grep -q "^f_${FUNC_NAME}() {" $DEF_TO_FILE; then
		# src/funcs.sh以外へ出力する場合でかつそこに関数定義が無い場合、
		# 関数定義のみ行う(それ以外はスキップする)
		SKIP='true'
	else
		exit 0
	fi
fi

if [ "$SKIP" = 'false' ]; then
	# 直前の関数のアドレスを設定している行番号を取得
	BEFORE_FUNC_ADDR_NR=$(sed -n "/^${TAB}a_${BEFORE_FUNC_NAME}=/=" src/funcs.sh)

	# 直後の関数定義の1行目の行番号を取得
	# (この行に関数定義を追加していく)
	INSERT_NR=$(awk "NR > ${BEFORE_FUNC_ADDR_NR} && /^${TAB}# / {print NR; exit}" src/funcs.sh)

	# 直後の関数の冒頭コメントと関数アドレス算出処理の見込み行数
	AFTER_FUNC_COMMENTS_ADRCALC_NRS=7

	# 直後の関数のアドレス算出処理を更新
	sed -i \
	    -e "${INSERT_NR},$((INSERT_NR + AFTER_FUNC_COMMENTS_ADRCALC_NRS))s#fsz=\$(to16 \$(stat -c '%s' src/f_${BEFORE_FUNC_NAME}.o))\$#fsz=\$(to16 \$(stat -c '%s' src/f_${FUNC_NAME}.o))#" \
	    -e "${INSERT_NR},$((INSERT_NR + AFTER_FUNC_COMMENTS_ADRCALC_NRS))s#=\$(calc16_8 \"\${a_${BEFORE_FUNC_NAME}}+\${fsz}\")\$#=\$(calc16_8 \"\${a_${FUNC_NAME}}+\${fsz}\")#" \
	    src/funcs.sh

	# 冒頭コメントと関数アドレス算出処理を追加
	## 追加処理
	sed -i \
	    -e "${INSERT_NR}i${TAB}# ${FUNC_DESC}" \
	    -e "${INSERT_NR}i${TAB}fsz=\$(to16 \$(stat -c '%s' src/f_${BEFORE_FUNC_NAME}.o))" \
	    -e "${INSERT_NR}i${TAB}a_${FUNC_NAME}=\$(calc16_8 \"\${a_${BEFORE_FUNC_NAME}}+\${fsz}\")" \
	    -e "${INSERT_NR}i${TAB}echo -e \"a_${FUNC_NAME}=\$a_${FUNC_NAME}\" >>\$map_file" \
	    -e "${INSERT_NR}i${TAB}f_${FUNC_NAME} >src/f_${FUNC_NAME}\.o" \
	    -e "${INSERT_NR}i${TAB}cat src/f_${FUNC_NAME}\.o" \
	    -e "${INSERT_NR}i\\\\" \
	    src/funcs.sh
fi

# 関数定義を中身空で追加
sed -i \
    -e "\$a\\\\" \
    -e "\$a# ${FUNC_DESC}" \
    -e "\$af_${FUNC_NAME}() {" \
    -e "\$a${TAB}# 変更が発生するレジスタを退避" \
    -e "\$a${TAB}## TODO" \
    -e "\$a\\\\" \
    -e "\$a${TAB}# TODO" \
    -e "\$a\\\\" \
    -e "\$a${TAB}# 退避したレジスタを復帰しreturn" \
    -e "\$a${TAB}## TODO" \
    -e "\$a${TAB}## return" \
    -e "\$a${TAB}sh2_return_after_next_inst" \
    -e "\$a${TAB}sh2_nop" \
    -e "\$a}" \
    $DEF_TO_FILE
