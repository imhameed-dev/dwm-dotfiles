#!/bin/sh

current=$(xprop -root _NET_CURRENT_DESKTOP 2>/dev/null | awk -F' = ' '{print $2}' | awk '{print $1}')
case "$current" in
    ''|*[!0-9]*) current=0 ;;
esac

count=5
output=
for i in $(seq 1 "$count"); do
    index=$((i - 1))
    if [ "$index" -eq "$current" ]; then
        output="$output%{F#1e1e1e}%{B#df6124} $i %{B-}%{F-} "
    else
        output="$output%{F#888888} $i %{F-} "
    fi
done
printf '%s\n' "$output"
