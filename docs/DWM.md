# DWM source

`dwm/` is dwm 6.5 (see `dwm/config.mk`) plus a few local changes. It contains everything needed to build and install it:
`dwm.c`, `drw.c`, `drw.h`, `util.c`, `util.h`, `config.h`, `config.mk`, `Makefile`, `dwm.1`, `LICENSE`.
There is no `config.def.h`; `dwm/config.h` is the only configuration. Upstream files that the build does not use (`README`, `dwm.png`, `transient.c`) are not included.

## Local changes (found by searching for the custom code; diff `dwm.c` against upstream 6.5 to confirm)

- Systray patch (suckless.org's official `systray` patch, adapted): docks `nm-applet`'s wifi icon in the bar. Adds the `Systray` struct, `updatesystray()`/`getsystraywidth()`/`wintosystrayicon()`/`resizebarwin()`/`systraytomon()` and related `Xembed`/`_NET_SYSTEM_TRAY_*` atom handling. Config: `showsystray`, `systrayonleft`, `systrayspacing`, `systraypinning`, `systraypinningfailfirst` in `config.h`.
- `outergap` (in `updatebarpos`): one gap-width of space on all four sides of the tiled area, including between the bar and windows below it.
- `restart()` (Super+Shift+R) re-executes `dwm`.
- `main()` runs `~/.autostart.sh` (`autostartcmd` in `config.h`) once after the windows are scanned.
- `config.h`: keybindings, `browsercmd`, tags 1-5, rules.

The bar's actual content (volume/battery/date-time) comes from `dwmblocks/`, a separate program — see its own `config.h` for the 3 blocks. dwm itself only draws tags, the focused window's title, and the systray; nothing in `dwm.c` needs to change to add or edit dwmblocks blocks.

## Changing or updating dwm

The configuration is compiled into the binary, so every change to `config.h` (including the autostart script name or `outergap`) only takes effect after a rebuild:

```bash
cd ~/dwm-dotfiles
make -C dwm clean && make -C dwm && sudo make -C dwm install
./install.sh --check
```

Then restart dwm with Super+Shift+R. To move to a newer upstream dwm, download it from suckless.org, diff its `dwm.c` against `dwm/dwm.c`, and re-apply the local changes above.

## Changing or updating dwmblocks

Same pattern, separate binary:

```bash
cd ~/dwm-dotfiles
make -C dwmblocks clean && make -C dwmblocks && sudo make -C dwmblocks install
pkill dwmblocks   # autostart's start() guard only launches it if it isn't already running
```
