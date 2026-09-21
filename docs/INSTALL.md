# Installation

Run the installer as your normal user from the repository root:

```bash
./install.sh
```

The installer detects the distribution, installs the core desktop packages, builds DWM from `dwm/`, installs user configuration, and installs `X11/40-libinput.conf` to `/etc/X11/xorg.conf.d/40-libinput.conf`.

Use `--dry-run` to preview the actions and `--yes` to skip the confirmation prompt. The installer ends with a verification (installed files match the repo, scripts are executable, dwm is the current build, required commands exist) and prints `Checks: N passed, N failed`. Run `./install.sh --check` at any time to repeat only that verification. Running it again rebuilds dwm and replaces changed files (backed up first).

Before replacing a different existing file, the installer moves it to a timestamped folder under `~/.local/state/dwm-dotfiles/backups/`.

The installer does not download or clone another DWM source tree. The `dwm/` directory in this repository is authoritative.


The installer enables and starts NetworkManager when systemd is available.
