#!/bin/sh
# Polybar "tail" script: prints the focused app's WM_CLASS name on every focus change.
# Event-driven: xprop -spy sleeps until dwm changes _NET_ACTIVE_WINDOW, so there is no polling.
xprop -spy -root _NET_ACTIVE_WINDOW | while read -r line; do
    id=${line##* }
    name=Desktop
    case $id in
        0x0|found.) ;;
        *)
            out=$(xprop -id "$id" WM_CLASS 2>/dev/null)
            case $out in
                *', "'*) name=${out##*, \"}; name=${name%\"} ;;
            esac
            ;;
    esac
    echo "$name"
done
