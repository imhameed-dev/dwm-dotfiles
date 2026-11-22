#!/bin/sh
# Volume text for the bar: an icon and the percent ("65%"), or a muted icon.
# Icons need the Nerd symbols font; without it the text is "Vol 65%" or "Vol Mute".
# The bar (dwmblocks) runs this when a volume key is pressed. Nothing runs in between.

icons=0
fc-list : family 2>/dev/null | grep -qi 'symbols nerd' && icons=1

vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5; exit}')
[ -n "$vol" ] || exit 0

if pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -q yes; then
    if [ "$icons" -eq 1 ]; then printf '\357\200\246 Mute'; else printf 'Vol Mute'; fi
elif [ "$icons" -eq 1 ]; then
    printf '\357\200\250 %s' "$vol"
else
    printf 'Vol %s' "$vol"
fi
