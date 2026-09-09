.PHONY: all clean install uninstall

all:
	$(MAKE) -C dwm

clean:
	$(MAKE) -C dwm clean

install:
	$(MAKE) -C dwm install

uninstall:
	$(MAKE) -C dwm uninstall
