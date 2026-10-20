CC = cc
CFLAGS = -std=c99 -pedantic -Wall -Os -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_XOPEN_SOURCE=700L $(shell pkg-config --cflags x11)
LDFLAGS = $(shell pkg-config --libs x11)
PREFIX = /usr/local

all: dwmblocks

dwmblocks: dwmblocks.c config.h
	$(CC) $(CFLAGS) -o dwmblocks dwmblocks.c $(LDFLAGS)

clean:
	rm -f dwmblocks *.o

install: dwmblocks
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f dwmblocks $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dwmblocks

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/dwmblocks

.PHONY: all clean install uninstall
