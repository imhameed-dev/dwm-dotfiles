#!/bin/sh
# Lock the screen with i3lock over your wallpaper, blurred and darkened.
#   lock-screen            lock now (stays in the foreground, as xss-lock needs)
#   lock-screen --prepare  only build the picture, then exit
# The picture is built once and kept in ~/.cache/lock-screen. If it is not ready
# (first lock, new wallpaper, different screens) the screen locks at once on plain
# black and the picture is built in the background for next time. Locking is never
# delayed. Needs ImageMagick and xrandr.

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

if [ -n "$img" ]; then
    if [ -f "$img" ]; then
        exec i3lock --nofork -i "$img"
    fi
    make_picture &
fi
exec i3lock --nofork --color=000000
