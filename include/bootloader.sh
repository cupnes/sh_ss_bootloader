if [ "${INCLUDE_BOOTLOADER_SH+is_defined}" ]; then
	return
fi
INCLUDE_BOOTLOADER_SH=true

# MIDIからロードするか否か
# - true : MIDIからロード
# - false: CD内のファイルからロード
LOAD_FROM_MIDI='true'

# 起動時にNBG0を非表示にしない
# - この変数を'true'に設定すると、
#   起動時にNBG0を非表示にしないため、
#   SEGAのロゴが表示されたままになる。
DISABLE_NBG0_OFF='false'
