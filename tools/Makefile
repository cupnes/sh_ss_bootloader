CFLAGS = -Wall -Wextra

all: dump_data_packets dump_cdloadable_data

dump_data_packets: dump_data_packets.c
	gcc $(CFLAGS) -o $@ $^

dump_cdloadable_data: dump_cdloadable_data.c
	gcc $(CFLAGS) -o $@ $^

clean:
	rm -f *~ dump_data_packets dump_cdloadable_data

.PHONY: clean
