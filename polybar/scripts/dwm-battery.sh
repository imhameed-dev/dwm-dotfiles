#!/bin/sh

battery=""
for path in /sys/class/power_supply/BAT*; do
    [ -d "$path" ] || continue
    battery="$path"
    break
done

[ -n "$battery" ] || exit 0

capacity=$(cat "$battery/capacity" 2>/dev/null || true)
status=$(cat "$battery/status" 2>/dev/null || true)
case "$capacity" in
    ''|*[!0-9]*) exit 0 ;;
esac

case "$status" in
    Charging) printf '+%s%%\n' "$capacity" ;;
    Discharging) printf '%s%%\n' "$capacity" ;;
    Full) printf '%s%%\n' "$capacity" ;;
    *) printf '%s%%\n' "$capacity" ;;
esac
