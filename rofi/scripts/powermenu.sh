#!/bin/bash

uptime_str=$(uptime -p)
uptime_str=${uptime_str#up }

lock="Lock"
sleep_opt="Sleep"
logout="Log out"
restart="Reboot"
shutdown="Shut down"

# Ask Yes/No first. "No" is the first entry, so a quick Enter or a misclick does nothing.
confirm() {
    local answer
    answer=$(printf "No\nYes" | \
        rofi -dmenu -i -theme ~/.config/rofi/powermenu.rasi \
        -theme-str 'listview { columns: 2; }' -mesg "$1" -p "Sure?")
    [ "$answer" = "Yes" ]
}

selected=$(printf "%s\n%s\n%s\n%s\n%s" "$lock" "$sleep_opt" "$logout" "$restart" "$shutdown" | \
    rofi -dmenu -i -theme ~/.config/rofi/powermenu.rasi \
    -mesg "Goodbye $USER" -p "Uptime: $uptime_str")

case "$selected" in
    "$lock") i3lock ;;
    "$sleep_opt") i3lock && systemctl suspend ;;
    "$logout") confirm "Log out?" && pkill -x dwm ;;
    "$restart") confirm "Reboot now?" && systemctl reboot ;;
    "$shutdown") confirm "Shut down now?" && systemctl poweroff ;;
esac
