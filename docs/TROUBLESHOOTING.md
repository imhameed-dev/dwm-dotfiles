# Troubleshooting

## DWM does not start

From a TTY, run:

```bash
make -C dwm clean
make -C dwm
startx
```

Check `~/.xinitrc` and make sure it ends with `exec dwm`.

## Gap between the bar and windows looks wrong

`updatebarpos()` in `dwm/config.h`-adjacent `dwm/dwm.c` adds one `outergap` of space below the bar (matching the gap on the other three screen edges). Change `outergap` in `dwm/config.h` to adjust it, then rebuild dwm (see `docs/DWM.md`).

## Workspace indicator does not update

Tags are drawn directly by dwm in its own bar — there's no separate module or property to check. If tags stop updating, it's a dwm bug, not a bar/config issue; check `dmesg`/`journalctl` for a crashed dwm process (Super+Shift+R restarts it).

## Nothing starts (no wallpaper, dwmblocks or tray)

dwm runs `~/.autostart.sh` (`autostartcmd` in `dwm/config.h`). If you rename that file, nothing is started; rename it back or change `autostartcmd` and rebuild dwm.

## Volume/battery/time not showing, or volume not updating live

- Nothing in the bar's status area: confirm `dwmblocks` is actually running (`pgrep -x dwmblocks`) and that `~/.autostart.sh` starts it.
- Volume percentage doesn't change when you press the volume keys: the volume keybinds in `dwm/config.h` must send `pkill -RTMIN+10 dwmblocks` after changing the volume (the block only refreshes on that signal, not on a timer — see `dwmblocks/config.h`).
- Battery block shows nothing: it reads the first `/sys/class/power_supply/BAT*` it finds and prints nothing on a machine without a battery. Check with `ls /sys/class/power_supply/`.

## Touchpad tapping

The installer places:

```text
/etc/X11/xorg.conf.d/40-libinput.conf
```

Restart the X session after installation. The configuration enables libinput tapping, standard left/right/middle mapping, and disables natural scrolling.

## Restore a previous configuration

Backups are stored under:

```text
~/.local/state/dwm-dotfiles/backups/
```

Each installation run that replaces files creates a timestamped backup directory.
