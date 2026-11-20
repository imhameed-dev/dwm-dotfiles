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
start nm-applet
start picom -b
