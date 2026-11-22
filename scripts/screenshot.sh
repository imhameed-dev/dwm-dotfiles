#!/bin/sh
# Take a screenshot with scrot. Usage:
#   screenshot full   all screens together
#   screenshot area   drag a box with the mouse (Esc cancels)
# The PNG goes to ~/Pictures/screenshots and a notice shows the file name.

dir="$HOME/Pictures/screenshots"

if ! command -v scrot >/dev/null 2>&1; then
    notify-send -u critical "Screenshot" "scrot is not installed" 2>/dev/null
    exit 1
fi

mkdir -p "$dir" || exit 1
file="$dir/$(date '+%F_%H-%M-%S').png"

case "$1" in
    full) scrot "$file" ;;
    area) scrot --select "$file" ;;
    *) echo "usage: screenshot full|area" >&2; exit 2 ;;
esac

# After Esc (or a failure) there is no file, so there is no notice.
[ -f "$file" ] && notify-send "Screenshot saved" "$file"
exit 0
