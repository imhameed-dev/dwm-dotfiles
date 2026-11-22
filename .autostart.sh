#!/bin/sh
# Started once by dwm (autostartcmd in dwm/config.h), so the file must stay named ~/.autostart.sh (dwm runs it with sh, no chmod needed).
# Safe to re-run (Super+Shift+R): it only starts what is missing.

# Make failures visible: a typo'd binary name or a missing package shows up here
# instead of vanishing. The log is added to on every start (so an old error is not
# lost) and starts fresh once it passes about 100 KB. No daemon, no polling.
log="$HOME/.autostart.log"
[ -f "$log" ] && [ "$(wc -c <"$log")" -gt 100000 ] && : >"$log"
exec >>"$log" 2>&1
echo "--- $(date '+%F %T') ---"

# Start a program only if it is not already running. A program that is not
# installed is written to the log and shown as a notice.
start() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "not installed: $1"
        notify-send -u critical "Autostart" "$1 is not installed" 2>/dev/null
        return
    fi
    pgrep -x "$1" >/dev/null || "$@" &
}

# feh writes ~/.fehbg whenever the wallpaper menu picks one; fall back to the default.
{ sh "$HOME/.fehbg" || feh --bg-fill "$HOME/Pictures/wallpapers/wallpaper.jpg"; } 2>/dev/null &

# dunst and nm-applet read ~/.config/<name>/ by default.
start dunst
start dwmblocks
# nm-applet only exists when NetworkManager was installed; without it there is nothing to start.
command -v nm-applet >/dev/null 2>&1 && start nm-applet
start picom -b

# Auto-lock: after 10 minutes without keys or mouse the screen locks. xss-lock also
# locks before the laptop sleeps (lid close, if systemd-logind suspends on lid close,
# which is its default). To change the time, edit 600 (seconds).
if command -v xset >/dev/null 2>&1; then
    xset s on && xset s 600 600
else
    echo "not installed: xset (auto-lock timer not set)"
    notify-send -u critical "Autostart" "xset is not installed" 2>/dev/null
fi
# The lock screen is ~/.local/bin/lock-screen (blurred wallpaper); plain i3lock if it is missing.
locker="$HOME/.local/bin/lock-screen"
if [ -x "$locker" ]; then
    "$locker" --prepare &
    start xss-lock --transfer-sleep-lock -- "$locker"
else
    start xss-lock --transfer-sleep-lock -- i3lock --nofork --color=000000
fi
