CFLAGS = -Wall -Wextra

all: dump_data_packets

dump_data_packets: dump_data_packets.c
	gcc $(CFLAGS) -o $@ $^

clean:
	rm -f *~ dump_data_packets

.PHONY: clean
