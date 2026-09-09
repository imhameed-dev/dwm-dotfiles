#!/bin/sh
exec > /tmp/dwm-autostart.log 2>&1

echo "START"

# DWM exports these values from dwm/polybar-height.h before launching autostart.
: "${DWM_POLYBAR_HEIGHT:=34}"
: "${DWM_POLYBAR_TOP_GAP:=8}"
: "${DWM_POLYBAR_BOTTOM_GAP:=8}"
export DWM_POLYBAR_HEIGHT DWM_POLYBAR_TOP_GAP DWM_POLYBAR_BOTTOM_GAP

DWM_WIFI_INTERFACE=$(
    ip -o link show |
    awk -F': ' '$2 ~ /^wl/ || $2 ~ /^wlan/ {print $2; exit}'
)
[ -n "$DWM_WIFI_INTERFACE" ] && export DWM_WIFI_INTERFACE

pkill -x picom 2>/dev/null || true
pkill -x polybar 2>/dev/null || true
pkill -x nm-applet 2>/dev/null || true
pkill -x dunst 2>/dev/null || true

picom --config "$HOME/.config/picom/picom.conf" &
sleep 2

until xprop -root _NET_SUPPORTING_WM_CHECK >/dev/null 2>&1; do sleep 0.2; done

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
LAST_WALLPAPER="$HOME/.cache/wallpaper-menu/last"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/wallpaper.jpg"
mkdir -p "$WALLPAPER_DIR"

if [ -f "$LAST_WALLPAPER" ]; then
    LAST_PATH=$(<"$LAST_WALLPAPER")
    if [ -f "$LAST_PATH" ]; then
        feh --bg-fill "$LAST_PATH" &
    elif [ -f "$DEFAULT_WALLPAPER" ]; then
        feh --bg-fill "$DEFAULT_WALLPAPER" &
    fi
elif [ -f "$DEFAULT_WALLPAPER" ]; then
    feh --bg-fill "$DEFAULT_WALLPAPER" &
fi

polybar main &
nm-applet &
dunst --config "$HOME/.config/dunst/dunstrc" &
