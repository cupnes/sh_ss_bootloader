# Data Transfer Over CD
if [ "${SRC_DTOCD_SH+is_defined}" ]; then
	return
fi
SRC_DTOCD_SH=true

. include/sh2.sh
. include/ss.sh
. include/common.sh

# 一連のデータロード処理を行う
# in  : r1 - ロード先アドレス
# out : r1 - 次にデータをロードするアドレス
#            (ロード先アドレス + ロードしたバイト数)
#     : r2 - チェックサム
f_load_data_from_cd() {
	# 変更が発生するレジスタを退避
	## r0
	sh2_add_to_reg_from_val_byte r15 $(two_comp_d 4)
	sh2_copy_to_ptr_from_reg_long r15 r0

	# TODO

	# 退避したレジスタを復帰しreturn
	## r0
	sh2_copy_to_reg_from_ptr_long r0 r15
	sh2_add_to_reg_from_val_byte r15 04
	## return
	sh2_return_after_next_inst
	sh2_nop
}