# DWM Dotfiles

Fast, lightweight DWM desktop setup for Linux.

## Install

```bash
git clone https://github.com/imhameed-dev/dwm-dotfiles.git
cd dwm-dotfiles
./install.sh
```

The installer automatically detects your Linux distribution, installs the required packages, builds and installs the DWM source included in this repository, installs the desktop configuration, and installs the X11 touchpad configuration.

**You do not need to install DWM separately or manually copy the configuration files.**

## Start

```bash
startx
```

## Supported

- Arch Linux and Arch-based distributions
- Debian
- Ubuntu
- Linux Mint
- Other compatible Debian-based distributions

## Included

- DWM
- Xorg / Xinit
- Polybar
- Picom
- Rofi
- Alacritty
- Dunst
- Feh
- NetworkManager
- libinput touchpad configuration
- Firefox
- Thunar
- Brightness control
- Fonts
- Required X11 utilities
- PipeWire / WirePlumber audio

## Wallpaper menu

The installer automatically creates `~/Pictures/wallpapers` and installs the repository wallpaper collection there. Press **Super+W** to open the Rofi wallpaper picker. The last selected wallpaper is restored on the next DWM session.

## Keyboard shortcuts

- **Super+Enter** - Alacritty
- **Super+Space** - Rofi
- **Super+W** - wallpaper menu
- **Super+B** - Firefox / Firefox ESR
- **Super+E** - Thunar
- **Super+P** - dmenu
- **Super+Shift+S** - power menu
- **Super+Q** - close window
- **Super+Shift+R** - restart DWM
- **Super+Shift+Q** - quit DWM

## Options

Preview the installation without changing your system:

```bash
./install.sh --dry-run
```

Install without prompts:

```bash
./install.sh --yes
```

Repair the existing installation:

```bash
./install.sh --repair
```

Uninstall files managed by this project:

```bash
./install.sh --uninstall
```

Show all available options:

```bash
./install.sh --help
```

The installer is designed to be safe to run more than once. Existing managed configuration files are backed up before they are replaced.

## Documentation

Advanced documentation is available in the `docs/` directory:

- `docs/INSTALL.md` - detailed installation information
- `docs/ARCH.md` - Arch Linux notes
- `docs/DEBIAN.md` - Debian-family notes
- `docs/TROUBLESHOOTING.md` - troubleshooting

## License

This project uses the license included in the repository.
# dwm-dotfiles
