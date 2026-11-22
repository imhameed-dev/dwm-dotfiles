#!/bin/sh
# Lock the screen with i3lock over your wallpaper, blurred and darkened.
#   lock-screen            lock now (stays in the foreground, as xss-lock needs)
#   lock-screen --prepare  only build the picture, then exit
# With i3lock-color (AUR on Arch) the lock screen also shows the weekday, a big
# day number, and the time and month, updated every second. With plain i3lock it
# shows only the picture. If the picture is not ready (first lock, new wallpaper,
# different screens) the screen locks at once on plain black and the picture is
# built in the background for next time. Locking is never delayed.
# Needs ImageMagick and xrandr.

mode=$1
cache="${XDG_CACHE_HOME:-$HOME/.cache}/lock-screen"

# The wallpaper that feh set (first picture in ~/.fehbg), or the default one.
wall=$(sed -n "s/^[^']*'\([^']*\)'.*/\1/p" "$HOME/.fehbg" 2>/dev/null | head -n 1)
[ -f "$wall" ] || wall="$HOME/Pictures/wallpapers/wallpaper.jpg"

# Size of all screens together (a second monitor makes it wider).
size=$(xrandr 2>/dev/null | sed -n 's/.*current \([0-9]*\) x \([0-9]*\),.*/\1 \2/p')
w=${size% *}
h=${size#* }

img=""
if [ -n "$w" ] && [ -n "$h" ] && [ -f "$wall" ]; then
    key=$(printf '%s' "$wall $w $h $(stat -c %Y "$wall")" | cksum | cut -d' ' -f1)
    img="$cache/$key.png"
fi

# Build the picture: shrink to a tenth, darken, then stretch back up (that is the blur).
make_picture() {
    mkdir -p "$cache" || return 1
    im=magick
    command -v magick >/dev/null 2>&1 || im=convert
    sw=$((w / 10))
    sh=$((h / 10))
    tmp="$cache/new.$$.png"
    if "$im" "$wall" -resize "${sw}x${sh}^" -gravity center -extent "${sw}x${sh}" \
            -modulate 70 -resize "${w}x${h}!" "png:$tmp" 2>/dev/null; then
        mv "$tmp" "$img"
        find "$cache" -name '*.png' ! -name "$key.png" -delete
    else
        rm -f "$tmp"
        return 1
    fi
}

if [ "$mode" = "--prepare" ]; then
    [ -n "$img" ] && [ ! -f "$img" ] && make_picture
    exit 0
fi

# Arguments for i3lock: the picture if it is ready, else plain black.
if [ -n "$img" ] && [ -f "$img" ]; then
    set -- --nofork -i "$img"
else
    [ -n "$img" ] && make_picture &
    set -- --nofork --color=000000
fi

# Only i3lock-color can draw the text. Every screen gets its own centered copy.
# i3lock-color says "version 2.13.c.5" (the .c. marks it); plain i3lock says "version 2.16".
if i3lock --version 2>&1 | grep -qE 'version [0-9.]*\.c\.|color'; then
    set -- "$@" --clock \
        --greeter-text="$(date +%A)" --greeter-size=22 --greeter-pos="x+w/2:y+h/2-95" \
        --time-str="%d" --time-size=130 --time-pos="x+w/2:y+h/2+30" \
        --date-str="%H:%M · %B" --date-size=28 --date-pos="x+w/2:y+h/2+85" \
        --greeter-color=ffffffff --time-color=ffffffff --date-color=ffffffff \
        --radius=45 --ring-width=6 --ind-pos="x+w/2:y+h-120" \
        --inside-color=00000000 --insidever-color=00000000 --insidewrong-color=00000000 \
        --ring-color=ffffffcc --ringver-color=ffffffff --ringwrong-color=ff6b6bff \
        --line-color=00000000 --separator-color=00000000 \
        --keyhl-color=ffffffff --bshl-color=ff6b6bff
    start=$(date +%s)
    i3lock "$@"
    rc=$?
    # i3lock-color quit at once with an error (a bad option): lock plain black instead.
    if [ "$rc" -ne 0 ] && [ $(($(date +%s) - start)) -lt 2 ]; then
        exec i3lock --nofork --color=000000
    fi
    exit "$rc"
fi

exec i3lock "$@"
