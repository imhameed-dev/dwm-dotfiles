#!/bin/bash

uptime_str=$(uptime -p | sed 's/^up //')

lock="Lock"
sleep_opt="Sleep"
logout="Log out"
restart="Reboot"
shutdown="Shut down"

selected=$(printf "%s\n%s\n%s\n%s\n%s" "$lock" "$sleep_opt" "$logout" "$restart" "$shutdown" | \
    rofi -dmenu -i -theme ~/.config/rofi/powermenu.rasi \
    -mesg "Goodbye ghost" -p "Uptime: $uptime_str")

case "$selected" in
    "$lock") i3lock ;;
    "$sleep_opt") systemctl suspend ;;
    "$logout") pkill -x dwm ;;
    "$restart") systemctl reboot ;;
    "$shutdown") systemctl poweroff ;;
esac
