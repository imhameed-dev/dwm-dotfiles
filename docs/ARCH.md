# Arch Linux

The installer uses `pacman` and the current Arch package names for the core desktop. Audio uses PipeWire, `pipewire-pulse`, and WirePlumber rather than a legacy PulseAudio-only setup.

Core packages include Xorg/Xinit, libinput, X11 utilities, Polybar, Picom, Rofi, Alacritty, Dunst, Feh, Firefox, Thunar, NetworkManager, `network-manager-applet`, `brightnessctl`, i3lock, Python, and JetBrains Mono.

During installation, the installer enables and starts the NetworkManager service when systemd is available. It does not modify unrelated services.

Build dependencies and the DWM source are kept inside this repository, so installation does not clone another DWM project.
