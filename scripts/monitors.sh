#!/bin/sh
# Set up the screens (Super+Shift+M runs this).
# Every connected screen is turned on at its best size, side by side from left to right,
# with the laptop's own screen first. Screens that are not connected are turned off.
# Run it after plugging in or unplugging a monitor.

screens=$(xrandr --query 2>/dev/null)
[ -n "$screens" ] || exit 1

connected=$(printf '%s\n' "$screens" | awk '$2 == "connected" { print $1 }')
gone=$(printf '%s\n' "$screens" | awk '$2 == "disconnected" { print $1 }')

# The laptop's own screen (eDP, LVDS or DSI) goes first, then the others in the order listed.
internal=$(printf '%s\n' "$connected" | grep -E '^(eDP|LVDS|DSI)')
others=$(printf '%s\n' "$connected" | grep -vE '^(eDP|LVDS|DSI)')

set --
prev=""
for out in $internal $others; do
    set -- "$@" --output "$out" --auto
    [ -n "$prev" ] && set -- "$@" --right-of "$prev"
    prev=$out
done
[ -n "$prev" ] || exit 1
for out in $gone; do
    set -- "$@" --output "$out" --off
done

xrandr "$@"
