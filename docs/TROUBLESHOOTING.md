# Troubleshooting

## DWM does not start

From a TTY, run:

```bash
make -C dwm clean
make -C dwm
startx
```

Check `~/.xinitrc` and make sure it ends with `exec dwm`.

## Polybar overlaps windows

Polybar is intentionally floating and dwm reserves space for it: `polybargap` in `dwm/config.h` must equal Polybar's `height` + `offset-y` + the gap below it (34 + 8 + 8 = 50 by default, values in `polybar/config.ini`). Rebuild dwm after changing `polybargap` (see `docs/DWM.md`), then run `pkill -x polybar` and restart dwm (Super+Shift+R); the autostart script never restarts a running Polybar.

## Workspace indicator does not update

The `internal/xworkspaces` module reads DWM's `_NET_CURRENT_DESKTOP` EWMH property. Verify with:

```bash
xprop -root _NET_CURRENT_DESKTOP
```

dwm publishes `_NET_DESKTOP_NAMES`, `_NET_DESKTOP_VIEWPORT` and `_NET_NUMBER_OF_DESKTOPS` at startup and updates `_NET_CURRENT_DESKTOP` when the view changes; Polybar's `internal/xworkspaces` module reads them. No helper scripts are involved.

## Nothing starts (no wallpaper, Polybar or tray)

dwm runs `~/.autostart.sh` (`autostartcmd` in `dwm/config.h`). If you rename that file, nothing is started; rename it back or change `autostartcmd` and rebuild dwm.

## Battery or Wi-Fi is missing

The battery and adapter names are set in `[module/battery]` of `polybar/config.ini` (`BAT1` and `ACAD` on this laptop). List yours with `grep . /sys/class/power_supply/*/type`. Wi-Fi needs Polybar 3.6+ (`interface-type`); on older versions set `interface = <name>` in `[module/wifi]`.

## App name in the bar shows an error

`polybar/appname.sh` is run with `sh` and needs `xprop`. Check that `~/.config/polybar/appname.sh` exists.

## Rounded corners are square

The rounded corners of Polybar and Rofi need a running compositor. Check with `pgrep -x picom`.

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
