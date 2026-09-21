#!/usr/bin/env bash
# Installs the dwm-dotfiles desktop on Arch- and Debian-family systems.
# shellcheck disable=SC2317  # have_* helpers are called through check()
set -Eeuo pipefail

SRC="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="${XDG_STATE_HOME:-$HOME/.local/state}/dwm-dotfiles/backups/$(date +%Y%m%d-%H%M%S)"
DRY=0
YES=0
CHECK=0
PASS=0
FAIL=0
PAIRS=()   # alternating: file in this repo, place it is installed to

usage() {
    cat <<'USAGE'
Usage: ./install.sh [--dry-run] [--yes] [--check] [-h|--help]

  --dry-run   print what would be done without changing anything
  --yes       do not ask for confirmation
  --check     only verify an existing installation (no changes)

Existing files that differ are moved to ~/.local/state/dwm-dotfiles/backups/ first.
USAGE
}

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# Run a command, or only print it with --dry-run.
run() {
    if ((DRY)); then
        printf '+'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

# put SRC DEST [sudo]: copy one file; *.sh files are always made executable (never
# depends on the mode the file had in the download), and a different old file is backed up.
put() {
    local src=$1 dest=$2 mode=644
    local -a as=()
    [[ ${3:-} == sudo ]] && as=(sudo)
    [[ $src == *.sh ]] && mode=755
    if [[ -L $dest ]] || { [[ -e $dest ]] && ! cmp -s "$src" "$dest"; }; then
        run mkdir -p "$BACKUP"
        run "${as[@]}" mv -- "$dest" "$BACKUP/${dest//\//_}"
    fi
    run "${as[@]}" install -Dm"$mode" "$src" "$dest"
}

# add_tree SRC_DIR DEST_DIR: remember every file below SRC_DIR and where it goes.
add_tree() {
    local f
    while IFS= read -r -d '' f; do
        PAIRS+=("$f" "$2/${f#"$1"/}")
    done < <(find "$1" -type f -print0)
}

# The one list of what goes where (used for both installing and verifying).
collect() {
    local d
    PAIRS+=("$SRC/.autostart.sh" "$HOME/.autostart.sh")
    PAIRS+=("$SRC/.xinitrc" "$HOME/.xinitrc")
    PAIRS+=("$SRC/.bash_profile" "$HOME/.bash_profile")
    for d in polybar picom rofi alacritty dunst; do
        add_tree "$SRC/$d" "$CONF/$d"
    done
    add_tree "$SRC/wallpapers" "$HOME/Pictures/wallpapers"
}

# check DESCRIPTION COMMAND...: count a passed or failed check.
check() {
    local desc=$1
    shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
        printf '  FAIL: %s\n' "$desc"
    fi
}

have_imagemagick() { command -v magick || command -v convert; }
have_firefox() { command -v firefox || command -v firefox-esr; }

verify() {
    local i src dest c
    log "Verifying"
    for ((i = 0; i < ${#PAIRS[@]}; i += 2)); do
        src=${PAIRS[i]}
        dest=${PAIRS[i + 1]}
        check "missing or different from the repo: $dest" cmp -s "$src" "$dest"
        if [[ $src == *.sh ]]; then
            check "not executable: $dest" test -x "$dest"
        fi
    done
    check "missing or different from the repo: /etc/X11/xorg.conf.d/40-libinput.conf" \
        cmp -s "$SRC/X11/40-libinput.conf" /etc/X11/xorg.conf.d/40-libinput.conf
    check "dwm is not installed in /usr/local/bin" test -x /usr/local/bin/dwm
    check "installed dwm does not start ~/.autostart.sh (rebuild and reinstall dwm)" \
        grep -q '\.autostart\.sh' /usr/local/bin/dwm
    for c in dwm startx polybar picom rofi alacritty dunst feh nm-applet pactl xprop \
             brightnessctl i3lock notify-send thunar; do
        check "command not found: $c" command -v "$c"
    done
    check "ImageMagick (magick or convert) not found" have_imagemagick
    check "Firefox (firefox or firefox-esr) not found" have_firefox
    printf '==> Checks: %d passed, %d failed\n' "$PASS" "$FAIL"
    ((FAIL == 0))
}

install_packages() {
    local -a common=(polybar picom rofi alacritty dunst feh imagemagick thunar brightnessctl i3lock)
    case $DISTRO in
        arch)
            run sudo pacman -S --needed -- "${common[@]}" \
                base-devel pkgconf libx11 libxft libxinerama \
                xorg-server xorg-xinit xorg-xrandr xorg-xinput xorg-xprop libinput \
                pipewire pipewire-audio pipewire-pulse wireplumber \
                networkmanager network-manager-applet libnotify ttf-jetbrains-mono firefox
            ;;
        debian)
            run sudo apt-get update
            run sudo apt-get install -y "${common[@]}" \
                build-essential pkg-config libx11-dev libxft-dev libxinerama-dev \
                xorg xinit x11-utils x11-xserver-utils xinput xserver-xorg-input-libinput libinput-tools \
                pipewire pipewire-audio pipewire-pulse wireplumber pulseaudio-utils \
                network-manager network-manager-gnome libnotify-bin fonts-jetbrains-mono
            run sudo apt-get install -y firefox || run sudo apt-get install -y firefox-esr
            ;;
    esac
}

main() {
    while (($#)); do
        case $1 in
            --dry-run) DRY=1 ;;
            --yes) YES=1 ;;
            --check) CHECK=1 ;;
            -h|--help) usage; exit 0 ;;
            *) die "unknown option: $1 (see --help)" ;;
        esac
        shift
    done

    ((EUID != 0)) || die "run this as a normal user, not root"
    collect
    if ((CHECK)); then
        verify
        exit
    fi
    [[ -r /etc/os-release ]] || die "cannot read /etc/os-release"
    # shellcheck disable=SC1091
    . /etc/os-release
    case " ${ID:-} ${ID_LIKE:-} " in
        *" arch "*) DISTRO=arch ;;
        *" debian "*|*" ubuntu "*) DISTRO=debian ;;
        *) die "unsupported distribution: ${PRETTY_NAME:-unknown}" ;;
    esac
    log "Detected ${PRETTY_NAME:-$DISTRO}"

    if ((!YES && !DRY)); then
        read -r -p "Install packages and copy the configuration? [y/N] " answer
        [[ $answer =~ ^[Yy] ]] || exit 1
    fi

    install_packages
    run sudo systemctl enable --now NetworkManager || log "could not enable NetworkManager; enable it yourself"

    log "Building and installing dwm"
    run make -C "$SRC/dwm" clean
    run make -C "$SRC/dwm"
    run sudo make -C "$SRC/dwm" install

    log "Copying configuration"
    local i
    for ((i = 0; i < ${#PAIRS[@]}; i += 2)); do
        put "${PAIRS[i]}" "${PAIRS[i + 1]}"
    done
    put "$SRC/X11/40-libinput.conf" /etc/X11/xorg.conf.d/40-libinput.conf sudo

    if ((!DRY)); then
        verify || die "$FAIL check(s) failed, see above"
    fi
    log "Done. Start dwm with: startx"
}

main "$@"
