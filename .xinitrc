#!/bin/sh

# DWM starts its own desktop components after X and DWM are initialized.
exec dwm
exec ~/.autostart.sh 
