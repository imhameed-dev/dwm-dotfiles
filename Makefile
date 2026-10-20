.PHONY: all clean install uninstall

all:
	$(MAKE) -C dwm
	$(MAKE) -C dwmblocks

clean:
	$(MAKE) -C dwm clean
	$(MAKE) -C dwmblocks clean

install:
	$(MAKE) -C dwm install
	$(MAKE) -C dwmblocks install

uninstall:
	$(MAKE) -C dwm uninstall
	$(MAKE) -C dwmblocks uninstall
