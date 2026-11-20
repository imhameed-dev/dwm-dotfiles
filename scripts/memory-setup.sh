#!/usr/bin/env bash
# Optional memory setup for Arch: compressed-RAM swap (zram) and earlyoom.
# Safe to run again. It never replaces an existing zram config.
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as your normal user, not root." >&2
    exit 1
fi

if [ ! -r /etc/arch-release ]; then
    echo "This script supports Arch only for now (Debian package names are not verified)." >&2
    exit 1
fi

conf=/etc/systemd/zram-generator.conf

echo "This will:"
echo "  1. install zram-generator and earlyoom"
echo "  2. create $conf if it does not exist (zstd, half of RAM)"
echo "  3. enable and start earlyoom"
read -r -p "Continue? [y/N] " answer
[[ $answer =~ ^[Yy]$ ]] || { echo "Nothing changed."; exit 0; }

sudo pacman -S --needed zram-generator earlyoom

if [ -e "$conf" ]; then
    echo "Keeping your existing $conf"
else
    printf '[zram0]\ncompression-algorithm = zstd\n' | sudo tee "$conf" >/dev/null
    echo "Created $conf. The zram swap starts after the next reboot."
fi

sudo systemctl enable --now earlyoom

echo "Done. Check with: swapon --show ; systemctl status earlyoom --no-pager"
