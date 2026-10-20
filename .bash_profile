#!/bin/sh

# Start the DWM X session automatically on the first local virtual console.
if [ -z "${DISPLAY:-}" ] && [ "$(tty 2>/dev/null || true)" = /dev/tty1 ]; then
    exec startx
fi
