# dwm-dotfiles

A small, fast Linux desktop for old or low-memory computers. It uses **dwm**, a tiny window manager, instead of a big desktop like GNOME or KDE, so it runs well even on 4 GB of RAM.

You only need `git`. The installer does the rest.

## Install

```bash
sudo pacman -S git        # Arch. On Debian, Ubuntu or Mint: sudo apt install git
git clone https://github.com/imhameed-dev/dwm-dotfiles.git
cd dwm-dotfiles
./install.sh
```

The installer asks for your password (`sudo`) because it installs programs. It then builds dwm and copies the settings. Any file it replaces is backed up first, so nothing is lost.

It also turns on a firewall that blocks incoming connections, creates your standard folders (Documents, Downloads, Pictures and so on), and gives the terminal its dark Gruvbox colours.

When it finishes, log out, switch to the text login screen (**Ctrl+Alt+F1**), and log in. The desktop starts by itself. If it does not, type `startx`.

If dwm was already running while you installed, it still uses the old setup. Close it with `pkill -x dwm`, then type `startx`.

## Works on

- **Arch Linux** - tested, including the firewall, folder and terminal steps.
- **Debian, Ubuntu, Linux Mint** - the installer supports them, but they are tested less. The firewall, folder and terminal steps have not been tested there.

## What you get

| Program | What it does |
| --- | --- |
| dwm | Arranges your windows. This is the core of the desktop. |
| dwmblocks | The top bar: volume, battery and clock. |
| Rofi | App launcher and menus. |
| xfce4-terminal | The terminal (where you type commands), in Gruvbox Dark Hard colours. |
| Dunst | Pop-up notifications. |
| Picom | Rounds the corners of Rofi menus, and nothing else. |
| Feh | Sets the wallpaper. |
| Firefox | Web browser. Super+B opens Brave instead if you have it. |
| PCManFM | File manager. `gvfs` adds trash and drive support. |
| NetworkManager | Wi-Fi and network, with an icon in the top bar. |
| PipeWire | Sound. |
| ufw | Firewall. Blocks incoming connections, allows outgoing ones. |
| Touchpad settings | Tap to click. |

## Keyboard shortcuts

**Super** is the Windows key.

| Keys | What happens |
| --- | --- |
| Super + Enter | Open a terminal |
| Super + Space | Open the app launcher |
| Super + W | Change the wallpaper |
| Super + B | Open the browser (Brave if installed, otherwise Firefox) |
| Super + E | Open the file manager |
| Super + Q | Close the window |
| Super + 1 to 5 | Go to workspace 1 to 5 |
| Super + Shift + 1 to 5 | Move the window to workspace 1 to 5 |
| Super + J / K | Switch between windows |
| Super + Shift + S | Power menu: lock, sleep, log out, reboot, shut down |
| Super + Shift + R | Restart dwm |

## If an AI assistant is helping you

Give it these rules:

1. Run only these steps, in order: install `git`, `git clone`, `./install.sh`, then `pkill -x dwm` and `startx`, then `./install.sh --check`.
2. Do not copy config files by hand. Installing a program does not install its settings. Only `./install.sh` does both.
3. If a check fails, send the lines that start with `FAIL`.

## Safe to try

You can look before you change anything:

```bash
./install.sh --dry-run   # show what would happen, change nothing
./install.sh --check     # check an existing install, change nothing
./install.sh --yes       # install without asking questions
./install.sh --help      # show all options
```

Running the installer twice is safe. Replaced files are saved in `~/.local/state/dwm-dotfiles/backups/`.

## More help

- [docs/INSTALL.md](docs/INSTALL.md) - install details
- [docs/DWM.md](docs/DWM.md) - change keys and the top bar
- [docs/ARCH.md](docs/ARCH.md) - notes for Arch Linux
- [docs/DEBIAN.md](docs/DEBIAN.md) - notes for Debian and similar
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - when something goes wrong

## License

See the [LICENSE](LICENSE) file.
