#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-menu"
THUMB_DIR="$CACHE_DIR/thumbs"
THEME="$(dirname "$(dirname "$(readlink -f "$0")")")/wallpaper-menu.rasi"
LAST_WALLPAPER_FILE="$CACHE_DIR/last"
THUMB_W=380
THUMB_H=220

mkdir -p "$THUMB_DIR"

command -v rofi >/dev/null 2>&1 || { echo "rofi not found" >&2; exit 1; }
command -v feh  >/dev/null 2>&1 || { echo "feh not found"  >&2; exit 1; }

# ImageMagick 7 renamed 'convert' to 'magick'; support either.
if command -v magick >/dev/null 2>&1; then
    CONVERT_CMD=(magick)
elif command -v convert >/dev/null 2>&1; then
    CONVERT_CMD=(convert)
else
    echo "imagemagick (convert/magick) not found" >&2
    exit 1
fi

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Menu" "Directory not found: $WALLPAPER_DIR" 2>/dev/null || true
    echo "Directory not found: $WALLPAPER_DIR" >&2
    exit 1
fi

thumb_for() {
    local src="$1"
    local base thumb
    base="$(basename "$src")"
    thumb="$THUMB_DIR/${base%.*}.png"
    if [ ! -f "$thumb" ] || [ "$src" -nt "$thumb" ]; then
        "${CONVERT_CMD[@]}" "$src" -resize "${THUMB_W}x${THUMB_H}^" \
                -gravity center -extent "${THUMB_W}x${THUMB_H}" \
                "$thumb" 2>/dev/null || cp "$src" "$thumb"
    fi
    echo "$thumb"
}

build_menu() {
    shopt -s nullglob nocaseglob
    local files=("$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp})
    shopt -u nullglob nocaseglob

    if [ "${#files[@]}" -eq 0 ]; then
        echo "No wallpapers found in $WALLPAPER_DIR" >&2
        exit 1
    fi

    for f in "${files[@]}"; do
        name="$(basename "$f")"
        name="${name%.*}"
        thumb="$(thumb_for "$f")"
        printf '%s\0icon\x1f%s\n' "$name" "$thumb"
    done
}

selection_name=$(build_menu | rofi \
    -dmenu \
    -i \
    -theme "$THEME" \
    -format "s")

[ -z "${selection_name:-}" ] && exit 0

chosen_file=""
shopt -s nullglob nocaseglob
for f in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp}; do
    base="$(basename "$f")"
    base="${base%.*}"
    if [ "$base" = "$selection_name" ]; then
        chosen_file="$f"
        break
    fi
done
shopt -u nullglob nocaseglob

if [ -z "$chosen_file" ]; then
    notify-send "Wallpaper Menu" "Could not resolve: $selection_name" 2>/dev/null || true
    exit 1
fi

feh --bg-fill "$chosen_file"
echo "$chosen_file" > "$LAST_WALLPAPER_FILE"
notify-send "Wallpaper" "Set to $(basename "$chosen_file")" 2>/dev/null || true
