#!/bin/sh
# Battery text for the bar, plus a notice at 15% and at 5% while the battery drains.
# Prints a battery icon and "85%" (a bolt icon while charging). Without the Nerd symbols font it prints
# "Bat 85%" ("Bat 85%+" while charging). Prints nothing at all on a PC without a battery.
# The last notice is remembered in a tiny file, so each one is shown once per drop. It is
# forgotten when the charger is plugged in or the level goes back above 15%.
# The bar (dwmblocks) runs this once a minute. Nothing runs in between.
# BATTERY_DIR can point to a test folder (the default is /sys/class/power_supply).

dir="${BATTERY_DIR:-/sys/class/power_supply}"
state="${XDG_RUNTIME_DIR:-/tmp}/battery-alert.$(id -u)"

cap=""
status=""
for b in "$dir"/BAT*; do
    [ -r "$b/capacity" ] || exit 0
    read -r cap <"$b/capacity"
    read -r status <"$b/status"
    break
done
case $cap in '' | *[!0-9]*) exit 0 ;; esac

icons=0
fc-list : family 2>/dev/null | grep -qi 'symbols nerd' && icons=1
if [ "$icons" -eq 1 ]; then
    if [ "$status" = "Charging" ]; then
        icon='\357\203\247'
    elif [ "$cap" -ge 88 ]; then
        icon='\357\211\200'
    elif [ "$cap" -ge 63 ]; then
        icon='\357\211\201'
    elif [ "$cap" -ge 38 ]; then
        icon='\357\211\202'
    elif [ "$cap" -ge 13 ]; then
        icon='\357\211\203'
    else
        icon='\357\211\204'
    fi
    printf "$icon %s%%" "$cap"
else
    mark=""
    [ "$status" = "Charging" ] && mark="+"
    printf 'Bat %s%%%s' "$cap" "$mark"
fi

level=0
if [ "$status" = "Discharging" ]; then
    if [ "$cap" -le 5 ]; then
        level=5
    elif [ "$cap" -le 15 ]; then
        level=15
    fi
fi

last=0
[ -r "$state" ] && read -r last <"$state"
case $last in '' | *[!0-9]*) last=0 ;; esac

if [ "$level" -ne 0 ] && { [ "$last" -eq 0 ] || [ "$level" -lt "$last" ]; }; then
    if [ "$level" -eq 5 ]; then
        notify-send -u critical "Battery almost empty" "$cap% left. Plug in the charger now." 2>/dev/null
    else
        notify-send "Battery low" "$cap% left. Plug in the charger." 2>/dev/null
    fi
fi
[ "$level" -eq "$last" ] || printf '%s\n' "$level" >"$state"
exit 0
