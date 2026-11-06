#!/bin/sh

# dwm runs ~/.autostart.sh itself once X and the WM are ready.
systemctl --user import-environment DISPLAY XAUTHORITY
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY

exec dwm
