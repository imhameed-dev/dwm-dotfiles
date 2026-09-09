#!/bin/sh

# DWM starts its own desktop components after X and DWM are initialized.
[ -x "$HOME/.dwm-autostart.sh" ] && "$HOME/.dwm-autostart.sh" &
exec dwm
