#!/bin/sh

# Start X automatically on the first virtual console.
[ -z "${DISPLAY:-}" ] && [ "$(tty)" = /dev/tty1 ] && exec startx
