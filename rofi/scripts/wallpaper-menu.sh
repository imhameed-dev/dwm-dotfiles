#!/usr/bin/env bash
# Rofi wallpaper picker. feh writes ~/.fehbg, which .autostart.sh replays at login.
set -euo pipefail

dir="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-menu"
theme="$(dirname "$(dirname "$(readlink -f "$0")")")/wallpaper-menu.rasi"
im=magick
command -v magick >/dev/null || im=convert

shopt -s nullglob nocaseglob
files=("$dir"/*.{jpg,jpeg,png,webp})
if ((${#files[@]} == 0)); then
    notify-send "Wallpaper Menu" "No wallpapers in $dir" || true
    exit 1
fi
mkdir -p "$cache"

menu() {
    local f thumb
    for f in "${files[@]}"; do
        thumb="$cache/${f##*/}.png"
        [[ $thumb -nt $f ]] || "$im" "$f" -resize 380x220^ -gravity center -extent 380x220 "$thumb" 2>/dev/null || cp "$f" "$thumb"
        printf '%s\0icon\x1f%s\n' "$(basename "${f%.*}")" "$thumb"
    done
}

# -format i prints the index of the chosen row, so no name lookup is needed.
i=$(menu | rofi -dmenu -i -theme "$theme" -format i) || exit 0
[[ -n $i ]] && feh --bg-fill "${files[i]}"
