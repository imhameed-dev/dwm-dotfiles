# dwm-dotfiles

A tiny, fast Linux desktop for old computers: the dwm window manager with a top bar, app launcher, notifications, Wi-Fi icon and sound. Tested on Arch Linux. Debian, Ubuntu and Mint are supported but tested less.

## Quick start

1. Install git: `sudo pacman -S git` (Arch) or `sudo apt install git` (Debian, Ubuntu).
2. Run: `git clone https://github.com/imhameed-dev/dwm-dotfiles.git && cd dwm-dotfiles && ./install.sh`
3. Log in on the text screen and the desktop starts by itself, or type `startx`. If dwm was already running, type `pkill -x dwm` first.

That is all. The rest explains what happened, for the curious.

## What the installer does

It asks for your password once (`sudo`), then:

- installs the programs: Xorg, dwm's build tools, Rofi (launcher), Dunst (notifications), Picom (rounds Rofi corners only), Feh (wallpaper), Thunar (files), xfce4-terminal, NetworkManager (Wi-Fi), PipeWire (sound), brightnessctl, i3lock, ImageMagick, Firefox and the JetBrains Mono font;
- builds dwm and the status bar (dwmblocks) from the source in this repo;
- copies the settings: `~/.xinitrc`, `~/.autostart.sh`, `~/.bash_profile`, `~/.config/rofi`, `dunst` and `picom`, the wallpapers in `~/Pictures/wallpapers`, the touchpad file `/etc/X11/xorg.conf.d/40-libinput.conf`, and the terminal colours (Gruvbox Dark Hard);
- turns on the `ufw` firewall (blocks incoming connections, allows outgoing ones) and creates your folders (Documents, Downloads and so on);
- checks everything and prints `Checks: N passed, 0 failed`.

Files it replaces are first moved to `~/.local/state/dwm-dotfiles/backups/`. Running it again is safe. The installer itself runs once and exits.

## How the desktop starts

You log in on the text screen (tty1), `.bash_profile` runs `startx`, `.xinitrc` starts dwm, and dwm runs `.autostart.sh` once. That script starts the status bar, notifications, Wi-Fi icon, Picom and the wallpaper. Its errors go to `~/.autostart.log`.

## Keys

Super is the Windows key. Super+Enter terminal, Super+Space launcher, Super+W wallpaper, Super+B browser (Brave if installed, otherwise Firefox), Super+E files, Super+Q close window, Super+1 to 5 workspaces (add Shift to move a window there), Super+J/K switch windows, Super+Shift+S power menu, Super+Shift+R restart dwm.

Browser: Firefox is installed by default and runs well on low-RAM machines, so it is the recommended choice there. Brave is optional: if you install it yourself, Super+B opens it instead.

## Change things

Change a file in this repo folder (for example `dwm/config.h` for keys, or `rofi/` for the launcher), then run `./install.sh` again. It rebuilds dwm and copies the files. Then press Super+Shift+R.

## If something is wrong

- `./install.sh --check` lists missing or different files as `FAIL` lines. Run `./install.sh` again to fix them.
- No status bar or wallpaper: dwm was probably already running during the install. Type `pkill -x dwm`, then `startx`.
- To preview without changing anything: `./install.sh --dry-run`. More details are in `docs/`.

AI assistants: run only the three quick-start steps, then `./install.sh --check`. Never copy files by hand, because installing a program does not install its settings. If a check fails, send the lines starting with `FAIL`.
