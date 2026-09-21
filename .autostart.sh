#!/bin/sh
# Started once by dwm (autostartcmd in dwm/config.h), so the file must stay named ~/.autostart.sh (dwm runs it with sh, no chmod needed).
# Safe to re-run (Super+Shift+R): it only starts what is missing.

# Start a daemon only if it is not already running.
start() { pgrep -x "$1" >/dev/null || "$@" & }

# feh writes ~/.fehbg whenever the wallpaper menu picks one; fall back to the default.
{ sh "$HOME/.fehbg" || feh --bg-fill "$HOME/Pictures/wallpapers/wallpaper.jpg"; } 2>/dev/null &

# picom (rounded corners of Polybar and Rofi need it), dunst and nm-applet read ~/.config/<name>/ by default.
start picom
start polybar main
start dunst
start nm-applet
