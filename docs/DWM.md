# DWM source

`dwm/` is dwm 6.5 (see `dwm/config.mk`) plus a few local changes. It contains everything needed to build and install it:
`dwm.c`, `drw.c`, `drw.h`, `util.c`, `util.h`, `config.h`, `config.mk`, `Makefile`, `dwm.1`, `LICENSE`.
There is no `config.def.h`; `dwm/config.h` is the only configuration. Upstream files that the build does not use (`README`, `dwm.png`, `transient.c`) are not included.

## Local changes (found by searching for the custom code; diff `dwm.c` against upstream 6.5 to confirm)

- `polybargap` and `outergap` (in `updatebarpos`): reserve space for the external Polybar and keep gaps at the screen edges. The built-in bar is off (`showbar = 0`).
- EWMH desktop properties for Polybar's workspace module: `_NET_DESKTOP_NAMES`, `_NET_DESKTOP_VIEWPORT`, `_NET_NUMBER_OF_DESKTOPS`, set once in `setup()`, and `_NET_CURRENT_DESKTOP`, updated by `updatecurrentdesktop()` in `setup`, `view`, `toggleview` and `focusmon`.
- `restart()` (Super+Shift+R) re-executes `dwm`.
- `main()` runs `~/.autostart.sh` (`autostartcmd` in `config.h`) once after the windows are scanned.
- `config.h`: keybindings, `browsercmd`, tags 1-5, rules.

## Changing or updating dwm

The configuration is compiled into the binary, so every change to `config.h` (including the autostart script name or `polybargap`) only takes effect after a rebuild:

```bash
cd ~/dwm-dotfiles
make -C dwm clean && make -C dwm && sudo make -C dwm install
./install.sh --check
```

Then restart dwm with Super+Shift+R. To move to a newer upstream dwm, download it from suckless.org, diff its `dwm.c` against `dwm/dwm.c`, and re-apply the local changes above.
