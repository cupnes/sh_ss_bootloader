if [ "${INCLUDE_BOOTLOADER_SH+is_defined}" ]; then
	return
fi
INCLUDE_BOOTLOADER_SH=true

# MIDIからロードするか否か
# - true : MIDIからロード
# - false: CD内のファイルからロード
LOAD_FROM_MIDI='false'
