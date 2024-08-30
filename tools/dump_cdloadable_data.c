#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SECTOR_SIZE 2048
#define HEADER_SECTOR_NUM 1

int main(int argc, char *argv[]) {
	if (argc != 3) {
		fprintf(stderr, "Usage: %s <input_file> <output_file>\n", argv[0]);
		return 1;
	}

	const char *input_file = argv[1];
	const char *output_file = argv[2];

	// 入力ファイルを開く
	FILE *in_fp = fopen(input_file, "rb");
	if (!in_fp) {
		perror("Failed to open input file");
		return 1;
	}

	// 入力ファイルのサイズを取得
	fseek(in_fp, 0, SEEK_END);
	long sz_exe_file = ftell(in_fp);
	fseek(in_fp, 0, SEEK_SET);

	// ヘッダの1セクタを除くセクタ数を計算
	long total_file_size = SECTOR_SIZE + sz_exe_file;
	long padding_size = SECTOR_SIZE - (sz_exe_file % SECTOR_SIZE);
	if (padding_size != SECTOR_SIZE) {
		total_file_size += padding_size;
	}
	unsigned char total_sectors = total_file_size / SECTOR_SIZE;
	unsigned char sectors_exc_header = total_sectors - HEADER_SECTOR_NUM;

	// チェックサムを計算
	unsigned char checksum = 0;
	for (long i = 0; i < sz_exe_file; i++) {
		int c = fgetc(in_fp);
		if (c == EOF) break;
		checksum += (unsigned char)c;
	}
	fseek(in_fp, 0, SEEK_SET); // ファイルポインタを先頭に戻す

	// 出力ファイルを開く
	FILE *out_fp = fopen(output_file, "wb");
	if (!out_fp) {
		perror("Failed to open output file");
		fclose(in_fp);
		return 1;
	}

	// バッファを用意
	unsigned char buffer[SECTOR_SIZE] = {0};

	// セクタ数とチェックサムを書き込む
	buffer[0] = sectors_exc_header;
	buffer[1] = checksum;
	fwrite(buffer, 1, SECTOR_SIZE, out_fp);

	// exe_file の内容を書き込む
	size_t bytes_read;
	while ((bytes_read = fread(buffer, 1, SECTOR_SIZE, in_fp)) > 0) {
		fwrite(buffer, 1, bytes_read, out_fp);
		memset(buffer, 0, SECTOR_SIZE); // バッファをゼロで埋める
	}

	// パディングが必要かどうか確認し、ゼロ値で埋める
	if (padding_size != SECTOR_SIZE) {
		memset(buffer, 0, padding_size);
		fwrite(buffer, 1, padding_size, out_fp);
	}

	fclose(in_fp);
	fclose(out_fp);

	printf("Conversion complete.\n");
	return 0;
}
