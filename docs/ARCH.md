# Arch Linux

The installer uses `pacman` and the current Arch package names for the core desktop. Audio uses PipeWire, `pipewire-pulse`, and WirePlumber rather than a legacy PulseAudio-only setup.

Core packages include Xorg/Xinit, libinput, X11 utilities, Rofi, xfce4-terminal, Dunst, Picom, Feh, ImageMagick, Firefox, Thunar with `gvfs`, NetworkManager, `network-manager-applet`, `brightnessctl`, i3lock, `ufw`, `xdg-user-dirs`, and JetBrains Mono. dwmblocks is built from source (see `docs/DWM.md`), not installed via pacman.

Browser: Firefox is installed by default and runs well on low-RAM machines, so it is the recommended choice there. Brave is optional: Super+B opens Firefox first and uses Brave only if Firefox is missing.

During installation, the installer enables and starts the NetworkManager service when systemd is available. It also enables the `ufw` firewall service. It does not modify other services.

Build dependencies and the DWM source are kept inside this repository, so installation does not clone another DWM project.
