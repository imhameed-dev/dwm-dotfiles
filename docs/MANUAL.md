# dwm-dotfiles: short manual for people

A tiny, fast Linux desktop for old computers. You do not need an AI to use it. If you do use an AI, give it `docs/AI.md`.

## Install

1. Install git: `sudo pacman -S git` (Arch) or `sudo apt install git` (Debian, Ubuntu).
2. Run: `git clone https://github.com/imhameed-dev/dwm-dotfiles.git && cd dwm-dotfiles && ./install.sh`
3. Install Brave Origin yourself (see below).
4. Log in on the text screen. The desktop starts by itself, or type `startx`. If dwm was already running, type `pkill -x dwm` first.

Use your normal user, not root. The installer asks for your password once. Your old files are saved in `~/.local/state/dwm-dotfiles/backups/` before anything is replaced.

## Keys (Super is the Windows key)

| Keys | Action |
| --- | --- |
| Super+Enter | terminal |
| Super+Space | app launcher |
| Super+B | browser |
| Super+E | files |
| Super+W | wallpaper |
| Super+Q | close window |
| Super+J / Super+K | switch windows |
| Super+1 to 5 | workspaces (add Shift to move a window there) |
| Super+Shift+S | power menu |
| Super+Shift+R | restart dwm |

## Browser (Brave Origin)

Super+B opens Brave Origin (command `brave-origin`). It is not in the normal package lists, so install it yourself: on Arch `yay -S brave-origin-bin`, on Debian or Ubuntu follow https://brave.com/origin/linux/. Then check the command with `command -v brave-origin`. The launch command was not verified. If it prints nothing, find the real command name and change `browsercmd` in `dwm/config.h`.

To use another browser, change `"brave-origin"` in the `browsercmd` line of `dwm/config.h` to that browser's command, then rebuild (next section).

## Change other keys or settings

Keys are in `dwm/config.h`. After you edit it:

```bash
make -C dwm clean && make -C dwm && sudo make -C dwm install
```

Then press Super+Shift+R. For other settings (`rofi/`, `dunst/`), edit the file in the repo folder and run `./install.sh` again.

## If something is wrong

- Run `./install.sh --check`. Lines that start with `FAIL` show what is missing. Run `./install.sh` again to fix it.
- No bar or wallpaper: dwm was already running during the install. Type `pkill -x dwm`, then `startx`. Errors are in `~/.autostart.log`.
- To see what the installer would do without changing anything: `./install.sh --dry-run`.
- Incoming connections are blocked by the firewall. See it with `sudo ufw status`.
