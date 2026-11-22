#!/bin/sh

# dwm runs ~/.autostart.sh itself once X and the WM are ready.
# Only on systems that have these programs (a system without systemd does not).
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user import-environment DISPLAY XAUTHORITY
fi
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd DISPLAY XAUTHORITY
fi

# Keyboard layout: change the one word below (examples: us, gb, de, fr, in), then log out and in.
# To try one at once without logging out, run: setxkbmap de
KBD_LAYOUT=us
if command -v setxkbmap >/dev/null 2>&1; then
    setxkbmap "$KBD_LAYOUT"
fi

# Screen size of text and icons (Xft.dpi) is in ~/.Xresources.
if [ -f "$HOME/.Xresources" ] && command -v xrdb >/dev/null 2>&1; then
    xrdb -merge "$HOME/.Xresources"
fi

exec dwm
