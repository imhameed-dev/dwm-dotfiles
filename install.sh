#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_DIR="$STATE_HOME/dwm-dotfiles"
BACKUP_ROOT="$STATE_DIR/backups"
MANIFEST="$STATE_DIR/manifest"

ASSUME_YES=0
DRY_RUN=0
REPAIR=0
UNINSTALL=0
DISTRO=""
PACKAGE_MANAGER=""
BACKUP_DIR=""

usage() {
    cat <<'USAGE'
Usage: ./install.sh [OPTION]

Install the dwm-dotfiles desktop on supported Arch and Debian-family systems.

Options:
  --dry-run     show what would be changed without changing the system
  --yes         accept prompts automatically
  --repair      repair the installation and replace managed files (backed up)
  --uninstall   remove unchanged files installed by this project
  -h, --help    show this help
USAGE
}

log()  { printf '==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

run() {
    if (( DRY_RUN )); then
        printf '+ '; printf '%q ' "$@"; printf '\n'
    else
        "$@"
    fi
}

sudo_run() {
    if (( DRY_RUN )); then
        printf '+ sudo '; printf '%q ' "$@"; printf '\n'
    else
        sudo "$@"
    fi
}

confirm() {
    local prompt=$1 answer
    (( ASSUME_YES || REPAIR )) && return 0
    [[ -t 0 ]] || return 1
    read -r -p "$prompt [y/N] " answer
    [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

sha256_file() {
    sha256sum -- "$1" | awk '{print $1}'
}

ensure_state_dir() {
    (( DRY_RUN )) || mkdir -p "$STATE_DIR" "$BACKUP_ROOT"
}

backup_path() {
    local source=$1 relative=$2 privileged=${3:-0} target
    if [[ -z "$BACKUP_DIR" ]]; then
        BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)-$$"
        run mkdir -p "$BACKUP_DIR"
    fi
    target="$BACKUP_DIR/$relative"
    run mkdir -p "$(dirname -- "$target")"
    if (( privileged )); then
        sudo_run mv -- "$source" "$target"
    else
        run mv -- "$source" "$target"
    fi
    log "Backed up $source -> $target"
}

record_file() {
    local destination=$1 source=$2 privileged=$3
    (( DRY_RUN )) && return 0
    mkdir -p "$STATE_DIR"
    local hash
    hash=$(sha256_file "$source")
    awk -F'\t' -v d="$destination" '$1 != d' "$MANIFEST" 2>/dev/null > "$MANIFEST.tmp" || true
    printf '%s\t%s\t%s\n' "$destination" "$hash" "$privileged" >> "$MANIFEST.tmp"
    mv -- "$MANIFEST.tmp" "$MANIFEST"
}

record_destination() {
    local destination=$1 privileged=$2 hash
    (( DRY_RUN )) && return 0
    if (( privileged )); then
        hash=$(sudo sha256sum -- "$destination" | awk '{print $1}')
    else
        hash=$(sha256_file "$destination")
    fi
    mkdir -p "$STATE_DIR"
    awk -F'\t' -v d="$destination" '$1 != d' "$MANIFEST" 2>/dev/null > "$MANIFEST.tmp" || true
    printf '%s\t%s\t%s\n' "$destination" "$hash" "$privileged" >> "$MANIFEST.tmp"
    mv -- "$MANIFEST.tmp" "$MANIFEST"
}

install_file() {
    local source=$1 destination=$2 mode=$3 relative=$4 privileged=${5:-0}
    [[ -f "$source" ]] || die "repository file is missing: $source"

    if [[ -L "$destination" || -e "$destination" ]]; then
        if [[ -f "$destination" ]] && cmp -s -- "$source" "$destination"; then
            log "Unchanged: $destination"
            record_file "$destination" "$source" "$privileged"
            return 0
        fi
        if ! confirm "Replace $destination?"; then
            warn "Keeping existing file: $destination"
            return 0
        fi
        backup_path "$destination" "$relative" "$privileged"
    fi

    if (( privileged )); then
        sudo_run install -D -m "$mode" "$source" "$destination"
    else
        run install -D -m "$mode" "$source" "$destination"
    fi
    record_file "$destination" "$source" "$privileged"
    log "Installed: $destination"
}

install_tree() {
    local source_root=$1 destination_root=$2 relative_root=$3
    local source relative mode
    [[ -d "$source_root" ]] || die "repository directory is missing: $source_root"
    while IFS= read -r -d '' source; do
        relative="${source#"$source_root"/}"
        mode=644
        [[ -x "$source" ]] && mode=755
        install_file "$source" "$destination_root/$relative" "$mode" "$relative_root/$relative" 0
    done < <(find "$source_root" -type f -not -path '*/__pycache__/*' -not -name '*.pyc' -not -name '*.swp' -print0 | sort -z)
}

detect_distribution() {
    [[ -r /etc/os-release ]] || die "cannot read /etc/os-release"
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}" in
        arch|manjaro|endeavouros) DISTRO=arch; PACKAGE_MANAGER=pacman ;;
        debian|ubuntu|linuxmint|mint|pop|elementary|zorin|kali) DISTRO=debian; PACKAGE_MANAGER=apt-get ;;
        *)
            case " ${ID_LIKE:-} " in
                *" arch "*) DISTRO=arch; PACKAGE_MANAGER=pacman ;;
                *" debian "*) DISTRO=debian; PACKAGE_MANAGER=apt-get ;;
                *) die "unsupported distribution: ${PRETTY_NAME:-${ID:-unknown}}" ;;
            esac
            ;;
    esac
    require_command "$PACKAGE_MANAGER"
    log "Detected ${PRETTY_NAME:-$ID}"
}

arch_packages() {
    printf '%s\n' \
        base-devel pkgconf libx11 libxft libxinerama \
        xorg-server xorg-xinit xorg-xrandr xorg-xinput xorg-xprop xdotool libinput \
        pipewire pipewire-audio pipewire-pulse wireplumber \
        networkmanager network-manager-applet iproute2 \
        polybar picom rofi alacritty dunst feh imagemagick libnotify thunar brightnessctl i3lock dmenu \
        ttf-jetbrains-mono python
}

debian_packages() {
    printf '%s\n' \
        build-essential pkg-config libx11-dev libxft-dev libxinerama-dev \
        xorg xinit x11-utils x11-xserver-utils xinput xdotool xserver-xorg-input-libinput libinput-tools \
        pipewire pipewire-audio pipewire-pulse wireplumber pulseaudio-utils \
        network-manager network-manager-gnome iproute2 \
        polybar picom rofi alacritty dunst feh imagemagick libnotify-bin thunar brightnessctl i3lock dmenu \
        fonts-jetbrains-mono python3
}

package_available() {
    case $DISTRO in
        arch) pacman -Si -- "$1" >/dev/null 2>&1 ;;
        debian) apt-cache show "$1" >/dev/null 2>&1 ;;
    esac
}

install_packages() {
    local -a packages missing=()
    case $DISTRO in
        arch) mapfile -t packages < <(arch_packages) ;;
        debian) mapfile -t packages < <(debian_packages) ;;
    esac

    confirm "Install/update the desktop packages?" || die "package installation cancelled"

    if [[ $DISTRO == debian ]] && (( ! DRY_RUN )); then
        sudo_run apt-get update
    fi

    if (( ! DRY_RUN )); then
        for package in "${packages[@]}"; do
            package_available "$package" || missing+=("$package")
        done
        ((${#missing[@]} == 0)) || die "required package(s) are unavailable: ${missing[*]}"
    fi

    case $DISTRO in
        arch) sudo_run pacman -S --needed -- "${packages[@]}" ;;
        debian) sudo_run apt-get install -y "${packages[@]}" ;;
    esac
}


install_browser() {
    case $DISTRO in
        arch)
            package_available firefox || die "required package is unavailable: firefox"
            sudo_run pacman -S --needed -- firefox
            ;;
        debian)
            if package_available firefox; then
                sudo_run apt-get install -y firefox
            elif package_available firefox-esr; then
                sudo_run apt-get install -y firefox-esr
            else
                die "Firefox is required, but neither firefox nor firefox-esr is available from the configured APT repositories"
            fi
            ;;
    esac
}

configure_services() {
    log "Configuring NetworkManager service"
    if (( DRY_RUN )); then
        printf '%s\n' '+ sudo systemctl enable --now NetworkManager'
        return 0
    fi
    if command -v systemctl >/dev/null 2>&1; then
        if ! sudo systemctl enable --now NetworkManager; then
            warn "Could not enable/start NetworkManager automatically; enable it with your system service manager"
        fi
    else
        warn "systemd is not available; enable NetworkManager using your distribution's service manager"
    fi
}

build_dwm() {
    log "Building DWM from the repository source"
    run make -C "$SCRIPT_DIR/dwm" clean
    run make -C "$SCRIPT_DIR/dwm"
    if (( ! DRY_RUN )); then
        [[ -x "$SCRIPT_DIR/dwm/dwm" ]] || die "DWM build did not produce an executable"
    fi
    log "Installing DWM"
    sudo_run make -C "$SCRIPT_DIR/dwm" install
    record_file /usr/local/bin/dwm "$SCRIPT_DIR/dwm/dwm" 1
    record_destination /usr/local/share/man/man1/dwm.1 1
}

install_system_config() {
    install_file "$SCRIPT_DIR/X11/40-libinput.conf" \
        /etc/X11/xorg.conf.d/40-libinput.conf \
        644 etc/X11/xorg.conf.d/40-libinput.conf 1
}

verify_required_commands() {
    local command
    local -a commands=(dwm startx dmenu_run polybar picom rofi alacritty dunst feh nm-applet ip xrandr xinput xprop xdotool brightnessctl i3lock pactl notify-send systemctl)
    for command in "${commands[@]}"; do
        command -v "$command" >/dev/null 2>&1 || die "verification failed: command not found: $command"
    done
    if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
        die "verification failed: ImageMagick (magick/convert) is missing"
    fi
    if ! command -v firefox >/dev/null 2>&1 && ! command -v firefox-esr >/dev/null 2>&1; then
        die "verification failed: Firefox is not installed"
    fi
}

verify_files() {
    [[ -x "$HOME/.dwm-autostart.sh" ]] || die "verification failed: ~/.dwm-autostart.sh is missing or not executable"
    [[ -f "$HOME/.xinitrc" ]] || die "verification failed: ~/.xinitrc is missing"
    [[ -f "$HOME/.bash_profile" ]] || die "verification failed: ~/.bash_profile is missing"
    [[ -f "$CONFIG_HOME/dwm/polybar-height.h" ]] || die "verification failed: shared DWM/Polybar geometry file is missing"
    [[ "$(awk '$1 == "#define" && $2 == "POLYBAR_HEIGHT" {print $3; exit}' "$CONFIG_HOME/dwm/polybar-height.h")" =~ ^[0-9]+$ ]] || die "verification failed: invalid Polybar height"
    [[ "$(awk '$1 == "#define" && $2 == "POLYBAR_TOP_GAP" {print $3; exit}' "$CONFIG_HOME/dwm/polybar-height.h")" =~ ^[0-9]+$ ]] || die "verification failed: invalid Polybar top gap"
    [[ "$(awk '$1 == "#define" && $2 == "POLYBAR_BOTTOM_GAP" {print $3; exit}' "$CONFIG_HOME/dwm/polybar-height.h")" =~ ^[0-9]+$ ]] || die "verification failed: invalid Polybar bottom gap"
    [[ -f "$CONFIG_HOME/polybar/config.ini" ]] || die "verification failed: Polybar configuration is missing"
    [[ -x "$CONFIG_HOME/polybar/scripts/dwm-workspaces.sh" ]] || die "verification failed: workspace script is missing or not executable"
    [[ -x "$CONFIG_HOME/polybar/scripts/dwm-windowtitle.py" ]] || die "verification failed: title script is missing or not executable"
    [[ -f "$CONFIG_HOME/picom/picom.conf" ]] || die "verification failed: Picom configuration is missing"
    [[ -f "$CONFIG_HOME/rofi/config.rasi" ]] || die "verification failed: Rofi configuration is missing"
    [[ -f "$CONFIG_HOME/alacritty/alacritty.toml" ]] || die "verification failed: Alacritty configuration is missing"
    [[ -f "$CONFIG_HOME/dunst/dunstrc" ]] || die "verification failed: Dunst configuration is missing"
    [[ -f /etc/X11/xorg.conf.d/40-libinput.conf ]] || die "verification failed: X11 libinput configuration is missing"
    grep -q 'Driver "libinput"' /etc/X11/xorg.conf.d/40-libinput.conf || die "verification failed: libinput driver is not configured"
    grep -q 'Option "Tapping" "on"' /etc/X11/xorg.conf.d/40-libinput.conf || die "verification failed: touchpad tapping is not enabled"
    grep -q 'Option "TappingButtonMap" "lrm"' /etc/X11/xorg.conf.d/40-libinput.conf || die "verification failed: standard touchpad button mapping is not configured"
    grep -q 'Option "NaturalScrolling" "false"' /etc/X11/xorg.conf.d/40-libinput.conf || die "verification failed: natural scrolling is not disabled"
    source_height=$(awk '$1 == "#define" && $2 == "POLYBAR_HEIGHT" {print $3; exit}' "$SCRIPT_DIR/dwm/polybar-height.h")
    runtime_height=$(awk '$1 == "#define" && $2 == "POLYBAR_HEIGHT" {print $3; exit}' "$CONFIG_HOME/dwm/polybar-height.h")
    [[ "$source_height" == "$runtime_height" ]] || die "verification failed: DWM/Polybar geometry is out of sync"
    grep -q "height = \${env:DWM_POLYBAR_HEIGHT}" "$CONFIG_HOME/polybar/config.ini" || die "verification failed: Polybar does not use shared height"
    grep -q "offset-y = \${env:DWM_POLYBAR_TOP_GAP:8}" "$CONFIG_HOME/polybar/config.ini" || die "verification failed: Polybar does not use shared top gap"
    [[ -x "$CONFIG_HOME/rofi/scripts/wallpaper-menu.sh" ]] || die "verification failed: wallpaper menu is missing or not executable"
    [[ -d "$HOME/Pictures/wallpapers" ]] || die "verification failed: wallpaper directory is missing"
    [[ -f "$HOME/Pictures/wallpapers/wallpaper.jpg" ]] || die "verification failed: default wallpaper.jpg is missing"
    find "$HOME/Pictures/wallpapers" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -print -quit | grep -q . || die "verification failed: no supported wallpapers installed"
}

verify_installation() {
    verify_required_commands
    verify_files
    log "Installation verification passed."
}

uninstall() {
    local destination expected actual privileged
    [[ -f "$MANIFEST" ]] || die "no installation manifest found at $MANIFEST"
    confirm "Remove unchanged files installed by dwm-dotfiles?" || die "uninstall cancelled"
    while IFS=$'\t' read -r destination expected privileged; do
        [[ -n "$destination" ]] || continue
        if (( privileged )); then
            if ! sudo test -f "$destination"; then continue; fi
            actual=$(sudo sha256sum -- "$destination" | awk '{print $1}')
        else
            [[ -f "$destination" ]] || continue
            actual=$(sha256_file "$destination")
        fi
        if [[ "$actual" != "$expected" ]]; then
            warn "Keeping modified file: $destination"
            continue
        fi
        if (( privileged )); then sudo_run rm -f -- "$destination"; else run rm -f -- "$destination"; fi
        log "Removed: $destination"
    done < "$MANIFEST"
    if (( ! DRY_RUN )); then rm -f -- "$MANIFEST"; fi
    log "Uninstall complete. Package removal is intentionally not automatic."
}


install_wallpapers() {
    local source_dir="$SCRIPT_DIR/wallpapers"
    local destination_dir="$HOME/Pictures/wallpapers"
    [[ -d "$source_dir" ]] || die "repository wallpaper directory is missing: $source_dir"
    [[ -f "$source_dir/wallpaper.jpg" ]] || die "repository default wallpaper is missing: $source_dir/wallpaper.jpg"
    run mkdir -p "$destination_dir"
    local wallpaper installed=0
    while IFS= read -r -d '' wallpaper; do
        install_file "$wallpaper" "$destination_dir/$(basename "$wallpaper")" 644 "Pictures/wallpapers/$(basename "$wallpaper")"
        installed=1
    done < <(find "$source_dir" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0 | sort -z)
    (( installed )) || die "no supported wallpapers found in $source_dir"
    log "Wallpapers installed in $destination_dir"
}

install_desktop() {
    ensure_state_dir
    install_packages
    install_browser
    configure_services
    build_dwm
    install_file "$SCRIPT_DIR/.dwm-autostart.sh" "$HOME/.dwm-autostart.sh" 755 .dwm-autostart.sh
    install_file "$SCRIPT_DIR/.xinitrc" "$HOME/.xinitrc" 644 .xinitrc
    install_file "$SCRIPT_DIR/.bash_profile" "$HOME/.bash_profile" 644 .bash_profile
    install_file "$SCRIPT_DIR/dwm/polybar-height.h" "$CONFIG_HOME/dwm/polybar-height.h" 644 dwm/polybar-height.h
    install_tree "$SCRIPT_DIR/polybar" "$CONFIG_HOME/polybar" polybar
    install_tree "$SCRIPT_DIR/picom" "$CONFIG_HOME/picom" picom
    install_tree "$SCRIPT_DIR/rofi" "$CONFIG_HOME/rofi" rofi
    install_wallpapers
    install_tree "$SCRIPT_DIR/alacritty" "$CONFIG_HOME/alacritty" alacritty
    install_tree "$SCRIPT_DIR/dunst" "$CONFIG_HOME/dunst" dunst
    install_system_config
    (( DRY_RUN )) || verify_installation
}

main() {
    while (($#)); do
        case $1 in
            --dry-run) DRY_RUN=1; ASSUME_YES=1 ;;
            --yes) ASSUME_YES=1 ;;
            --repair) REPAIR=1; ASSUME_YES=1 ;;
            --uninstall) UNINSTALL=1 ;;
            -h|--help) usage; exit 0 ;;
            *) die "unknown option: $1" ;;
        esac
        shift
    done

    (( !(UNINSTALL && REPAIR) )) || die "--uninstall and --repair cannot be combined"
    (( EUID != 0 )) || die "run this installer as a normal user, not root"
    require_command sudo
    detect_distribution
    if (( UNINSTALL )); then
        uninstall
        exit 0
    fi

    require_command make
    [[ -f "$SCRIPT_DIR/dwm/Makefile" && -f "$SCRIPT_DIR/dwm/config.h" ]] || die "complete DWM source tree is missing"
    [[ -f "$SCRIPT_DIR/X11/40-libinput.conf" ]] || die "X11/40-libinput.conf is missing"
    [[ -x "$SCRIPT_DIR/rofi/scripts/wallpaper-menu.sh" ]] || die "rofi/scripts/wallpaper-menu.sh is missing or not executable"
    [[ -f "$SCRIPT_DIR/wallpapers/wallpaper.jpg" ]] || die "wallpapers/wallpaper.jpg is missing"
    install_desktop
    if (( DRY_RUN )); then
        log "Dry run complete; no files or packages were changed."
    else
        log "Installation complete. Start DWM with: startx"
        [[ -z "$BACKUP_DIR" ]] || log "Backups: $BACKUP_DIR"
    fi
}

main "$@"
