#!/bin/sh

# dwm runs ~/.autostart.sh itself once X and the WM are ready.
# Only on systems that have these programs (a system without systemd does not).
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user import-environment DISPLAY XAUTHORITY
fi
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd DISPLAY XAUTHORITY
fi

exec dwm
