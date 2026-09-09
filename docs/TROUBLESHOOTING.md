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

Polybar is intentionally floating. `POLYBAR_HEIGHT` controls bar thickness, while `POLYBAR_TOP_GAP` and `POLYBAR_BOTTOM_GAP` provide the breathing room around it. DWM reserves the sum of all three values and exports them to Polybar. Rebuild DWM after changing them.

## Workspace indicator does not update

The workspace module reads DWM's `_NET_CURRENT_DESKTOP` EWMH property. Verify with:

```bash
xprop -root _NET_CURRENT_DESKTOP
```

`xdotool` is required by the workspace helper and is installed by the core package set.

## Wi-Fi or battery is missing

The autostart script detects the active network interface and battery automatically. If no battery exists, the battery module is disabled for that session. This avoids hard-coded interface, battery, and adapter names.

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
