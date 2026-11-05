# Troubleshooting

## The desktop looks incomplete after installing

Run the check:

```bash
./install.sh --check
```

Each line that starts with `FAIL` names something that is missing or different. Run `./install.sh --yes` again to fix it. Installing a program does not install its settings, so a missing file usually means the installer has not finished.

## DWM does not start

From a TTY, run:

```bash
make -C dwm clean
make -C dwm
startx
```

Check `~/.xinitrc` and make sure it ends with `exec dwm`.

## Nothing starts (no wallpaper, status bar or tray)

dwm runs `~/.autostart.sh` (`autostartcmd` in `dwm/config.h`) once, when dwm starts.

- If you installed while dwm was already running, that dwm is still the old one. Close it with `pkill -x dwm`, then run `startx`.
- Read `~/.autostart.log`. It lists any errors from the startup script.
- If you renamed the file, nothing is started. Rename it back, or change `autostartcmd` and rebuild dwm.

## Gap between the bar and windows looks wrong

`updatebarpos()` in `dwm/dwm.c` adds one `outergap` of space below the bar, matching the gap on the other three screen edges. Change `outergap` in `dwm/config.h` to adjust it, then rebuild dwm (see `docs/DWM.md`).

## Workspace indicator does not update

Tags are drawn directly by dwm in its own bar, so there is no separate module to check. If they stop updating, dwm may have crashed: look in `dmesg` or `journalctl`, and restart it with Super+Shift+R.

## Volume/battery/time not showing, or volume not updating live

- Nothing in the bar's status area: confirm `dwmblocks` is actually running (`pgrep -x dwmblocks`) and that `~/.autostart.sh` starts it.
- Volume percentage doesn't change when you press the volume keys: the volume keybinds in `dwm/config.h` must send `pkill -RTMIN+10 dwmblocks` after changing the volume (the block only refreshes on that signal, not on a timer; see `dwmblocks/config.h`).
- Battery block shows nothing: it reads the first `/sys/class/power_supply/BAT*` it finds and prints nothing on a machine without a battery. Check with `ls /sys/class/power_supply/`.

## Touchpad tapping

The installer places:

```text
/etc/X11/xorg.conf.d/40-libinput.conf
```

Restart the X session after installation. The configuration enables libinput tapping, standard left/right/middle mapping, and disables natural scrolling.

## Firewall

The installer turns on the `ufw` firewall. It blocks incoming connections and allows outgoing ones, so browsing and updates are not affected.

- Show the state: `sudo ufw status`
- A program that must accept incoming connections needs a rule, for example `sudo ufw allow 8080/tcp`.
- Turn it off (not recommended): `sudo ufw disable`

## Restore a previous configuration

Backups are stored under:

```text
~/.local/state/dwm-dotfiles/backups/
```

Each installation run that replaces files creates a timestamped backup directory.
