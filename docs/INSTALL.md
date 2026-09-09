# Installation

Run the installer as your normal user from the repository root:

```bash
./install.sh
```

The installer detects the distribution, installs the core desktop packages, builds DWM from `dwm/`, installs user configuration, and installs `X11/40-libinput.conf` to `/etc/X11/xorg.conf.d/40-libinput.conf`.

Use `--dry-run` to preview actions, `--repair` to rebuild and replace managed files, and `--uninstall` to remove unchanged files installed by this project. Packages are deliberately not removed during uninstall.

Before replacing an existing managed file, the installer creates a timestamped backup under `~/.local/state/dwm-dotfiles/backups/`.

The installer does not download or clone another DWM source tree. The `dwm/` directory in this repository is authoritative.


The installer enables and starts NetworkManager when systemd is available.
