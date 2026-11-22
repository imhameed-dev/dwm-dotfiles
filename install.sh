#!/usr/bin/env bash
# Installs the dwm-dotfiles desktop on Arch- and Debian-family systems.
# shellcheck disable=SC2317  # have_* helpers are called through check()
set -Eeuo pipefail

SRC="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/dwm-dotfiles/backups"
BACKUP="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
DRY=0
YES=0
CHECK=0
FIREWALL=0
POWER=0
UNINSTALL=0
DOTFILES=0
PASS=0
FAIL=0
WARN=0
NM=1          # 1 = install and turn on NetworkManager, 0 = another network manager is in use
PAIRS=()   # alternating: file in this repo, place it is installed to
REMOVED=()  # files taken away by --uninstall

usage() {
    cat <<'USAGE'
Usage: ./install.sh [--dry-run] [--yes] [--check] [--firewall] [--power] [--dotfiles] [--uninstall] [-h|--help]

  --dry-run   print what would be done without changing anything
  --yes       do not ask for confirmation
  --check     only verify an existing installation (no changes)
  --firewall  also install and turn on the ufw firewall (incoming connections
              blocked; SSH is allowed first if an SSH server is installed).
              Without this option the firewall is not touched.
  --power     also install and turn on tlp (laptop power saving). Without this
              option power settings are not touched.
  --uninstall remove what this installer put in place (only files that are still
              exact copies of the repo's files; ones you changed are kept), then
              offer to restore your old files from the backups. Packages stay installed.
  --dotfiles  replace your own ~/.bashrc, ~/.bash_profile, ~/.xinitrc and ~/.Xresources with the
              ones from this repo (the old files are backed up first).
              Without this option files you already have and changed are kept.

Any file that is replaced is moved to ~/.local/state/dwm-dotfiles/backups/ first.
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

# personal DEST: true for the three files people usually edit by hand.
personal() {
    case $1 in
        "$HOME/.bashrc"|"$HOME/.bash_profile"|"$HOME/.xinitrc"|"$HOME/.Xresources") return 0 ;;
    esac
    return 1
}

# keep_personal DEST SRC: true when DEST is one of those files, already exists,
# differs from the repo, and --dotfiles was not given (so it must be left alone).
keep_personal() {
    personal "$1" && [[ -e $1 || -L $1 ]] && ! cmp -s "$2" "$1" && ((!DOTFILES))
}

# The one list of what goes where (used for both installing and verifying).
collect() {
    local d
    PAIRS+=("$SRC/.autostart.sh" "$HOME/.autostart.sh")
    PAIRS+=("$SRC/scripts/lock-screen.sh" "$HOME/.local/bin/lock-screen")
    PAIRS+=("$SRC/scripts/screenshot.sh" "$HOME/.local/bin/screenshot")
    PAIRS+=("$SRC/scripts/monitors.sh" "$HOME/.local/bin/monitors")
    PAIRS+=("$SRC/scripts/battery-alert.sh" "$HOME/.local/bin/battery-alert")
    PAIRS+=("$SRC/scripts/volume-status.sh" "$HOME/.local/bin/volume-status")
    PAIRS+=("$SRC/.xinitrc" "$HOME/.xinitrc")
    PAIRS+=("$SRC/.Xresources" "$HOME/.Xresources")
    PAIRS+=("$SRC/.bash_profile" "$HOME/.bash_profile")
    PAIRS+=("$SRC/.bashrc" "$HOME/.bashrc")
    PAIRS+=("$SRC/xfce4-terminal/xfce4-terminal.xml" "$CONF/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml")
    for d in rofi dunst picom; do
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

# optional DESCRIPTION COMMAND...: like check, but a miss is only a warning (the desktop still works).
optional() {
    local desc=$1
    shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS + 1))
    else
        WARN=$((WARN + 1))
        printf '  WARN: %s\n' "$desc"
    fi
}

have_imagemagick() { command -v magick || command -v convert; }
verify() {
    local i src dest c
    log "Verifying"
    for ((i = 0; i < ${#PAIRS[@]}; i += 2)); do
        src=${PAIRS[i]}
        dest=${PAIRS[i + 1]}
        if keep_personal "$dest" "$src"; then
            printf '  WARN: your own %s is different from the repo (kept; --dotfiles replaces it)\n' "$dest"
            continue
        fi
        if [[ $dest == "$HOME/Pictures/wallpapers/"* ]]; then
            # pictures are yours to add, change or delete: only a note
            optional "wallpaper missing or changed (fine if you chose it): $dest" cmp -s "$src" "$dest"
            continue
        fi
        check "missing or different from the repo: $dest" cmp -s "$src" "$dest"
        if [[ $src == *.sh ]]; then
            check "not executable: $dest" test -x "$dest"
        fi
    done
    check "missing or different from the repo: /etc/X11/xorg.conf.d/40-libinput.conf" \
        cmp -s "$SRC/X11/40-libinput.conf" /etc/X11/xorg.conf.d/40-libinput.conf
    check "missing or different from the repo: /usr/share/xsessions/dwm.desktop (login screen entry)" \
        cmp -s "$SRC/X11/dwm.desktop" /usr/share/xsessions/dwm.desktop
    check "dwm is not installed in /usr/local/bin" test -x /usr/local/bin/dwm
    check "installed dwm does not start ~/.autostart.sh (rebuild and reinstall dwm)" \
        grep -q '\.autostart\.sh' /usr/local/bin/dwm
    check "dwmblocks is not installed in /usr/local/bin" test -x /usr/local/bin/dwmblocks
    if ((FIREWALL)); then
        check "firewall (ufw) is not running" systemctl is-active --quiet ufw
    fi
    if ((POWER)); then
        check "tlp is not running" systemctl is-active --quiet tlp
    fi
    check "home folders were not created (Documents)" test -d "$HOME/Documents"
    for c in dwm dwmblocks startx rofi xfce4-terminal dunst picom feh pactl \
             xset xrandr setxkbmap xrdb notify-send; do
        check "command not found: $c" command -v "$c"
    done
    # Helpers for single features: a miss only turns that feature off.
    optional "nm-applet not found (no Wi-Fi tray icon)" command -v nm-applet
    optional "brightnessctl not found (brightness keys do nothing)" command -v brightnessctl
    optional "i3lock not found (no screen lock)" command -v i3lock
    optional "xss-lock not found (no automatic lock)" command -v xss-lock
    optional "scrot not found (no screenshots)" command -v scrot
    optional "pavucontrol not found (Super+V does nothing)" command -v pavucontrol
    optional "playerctl not found (media keys do nothing)" command -v playerctl
    optional "thunar not found (no file manager)" command -v thunar
    optional "ImageMagick (magick or convert) not found (lock screen stays plain black)" have_imagemagick
    # Brave Origin is not in the normal package lists, so a missing one is only a warning.
    command -v brave-origin >/dev/null 2>&1 || printf '  WARN: brave-origin not found (Super+B needs it; see docs/MANUAL.md)\n'
    printf '==> Checks: %d passed, %d warnings, %d failed\n' "$PASS" "$WARN" "$FAIL"
    ((FAIL == 0))
}

# other_network: print the name of another network manager that is in charge of this
# computer's network, or print nothing. NET_ROOT is only used by the tests.
other_network() {
    local r=${NET_ROOT:-} s f
    if systemctl is-active --quiet NetworkManager 2>/dev/null; then
        return 0
    fi
    for s in systemd-networkd connman dhcpcd iwd; do
        if systemctl is-active --quiet "$s" 2>/dev/null; then
            printf '%s' "$s"
            return 0
        fi
    done
    for f in "$r"/etc/netplan/*.yaml; do
        if [[ -e $f ]] && ! grep -qi 'renderer: *NetworkManager' "$f"; then
            printf 'netplan'
            return 0
        fi
    done
    if [[ -r $r/etc/network/interfaces ]] &&
        grep -Eq '^[[:space:]]*(iface|allow-hotplug|auto)[[:space:]]+[^[:space:]]+' <(grep -Ev '^[[:space:]]*(iface|allow-hotplug|auto)[[:space:]]+lo([[:space:]]|$)' "$r/etc/network/interfaces"); then
        printf 'ifupdown'
        return 0
    fi
    return 0
}

install_packages() {
    local -a net=()
    ((NM)) && net=(networkmanager network-manager-applet)
    local -a common=(rofi dunst feh imagemagick thunar brightnessctl i3lock xss-lock scrot pavucontrol playerctl xfce4-terminal picom xdg-user-dirs gvfs)
    if ((FIREWALL)); then
        common+=(ufw)
    fi
    if ((POWER)); then
        common+=(tlp)
    fi
    # i3lock-color (AUR, optional, shows a clock on the lock screen) replaces i3lock.
    # Asking pacman for i3lock then fails on the conflict, so leave i3lock out.
    if [[ $DISTRO == arch ]] && pacman -Q i3lock-color >/dev/null 2>&1; then
        local pkg
        local -a kept=()
        for pkg in "${common[@]}"; do
            [[ $pkg == i3lock ]] || kept+=("$pkg")
        done
        common=("${kept[@]}")
    fi
    case $DISTRO in
        arch)
            # -Syu (a full upgrade) is how Arch wants packages installed: a database
            # that is refreshed without upgrading can leave the system half-updated.
            local -a pm=(-Syu --needed)
            ((YES)) && pm+=(--noconfirm)
            log "Arch: updating the package database and the system, then installing"
            run sudo pacman "${pm[@]}" -- "${common[@]}" \
                base-devel pkgconf libx11 libxft libxinerama \
                xorg-server xorg-xinit libinput xorg-xset xorg-xrandr xorg-xrdb xorg-setxkbmap \
                pipewire pipewire-audio pipewire-pulse wireplumber \
                "${net[@]}" libnotify xdg-utils xdg-desktop-portal xdg-desktop-portal-gtk ttf-jetbrains-mono ttf-nerd-fonts-symbols-mono
            ;;
        debian)
            # The core packages are needed to build and start dwm, so a failure stops here.
            # The rest are tried together first, then one by one, so that one package
            # missing on an older release does not stop the others.
            local -a core=(build-essential pkg-config libx11-dev libxft-dev libxinerama-dev
                           xorg xinit x11-xserver-utils xserver-xorg-input-libinput
                           xdg-user-dirs libnotify-bin)
            local -a optional=() skipped=()
            local p nerd_note=0
            if ((NM)); then
                core+=(network-manager)
                optional+=(network-manager-gnome)
            fi
            for p in "${common[@]}" pipewire pipewire-audio pipewire-pulse wireplumber \
                     pulseaudio-utils fonts-jetbrains-mono; do
                [[ $p == xdg-user-dirs ]] || optional+=("$p")
            done
            run sudo apt-get update
            # Debian stable has no Nerd symbols font package yet; use it where it exists.
            if apt-cache show fonts-nerd-symbols >/dev/null 2>&1; then
                optional+=(fonts-nerd-symbols)
            else
                nerd_note=1
            fi
            run sudo apt-get install -y "${core[@]}"
            if ! run sudo apt-get install -y "${optional[@]}"; then
                log "Some optional packages could not be installed together; trying one by one"
                for p in "${optional[@]}"; do
                    run sudo apt-get install -y "$p" || skipped+=("$p")
                done
            fi
            if ((${#skipped[@]})); then
                log "WARNING: not installed (missing on this release): ${skipped[*]}"
            fi
            if ((nerd_note)); then
                log "NOTE: this release has no Nerd symbols font package, so the bar and the shell prompt show plain text. For icons, download Symbols Nerd Font Mono from https://www.nerdfonts.com/font-downloads into ~/.local/share/fonts and run: fc-cache -f"
            fi
            ;;
    esac
}

# ask QUESTION: true if the answer is yes (--yes answers yes to everything).
ask() {
    local answer
    ((YES)) && return 0
    read -r -p "$1 [y/N] " answer
    [[ $answer =~ ^[Yy] ]]
}

# remove_ours DEST SRC [sudo]: remove DEST only if it is an exact copy of SRC.
remove_ours() {
    local dest=$1 src=$2
    local -a as=()
    [[ ${3:-} == sudo ]] && as=(sudo)
    if [[ ! -e $dest && ! -L $dest ]]; then
        return 0
    fi
    if cmp -s "$src" "$dest"; then
        run "${as[@]}" rm -f -- "$dest"
        REMOVED+=("$dest")
    else
        printf '  Kept (it is different from the repo, so you changed it): %s\n' "$dest"
    fi
}

# oldest_backup DEST: print the oldest saved copy of DEST (the file you had before the
# first install), or fail when there is none.
oldest_backup() {
    local name=${1//\//_} d
    for d in "$BACKUP_ROOT"/*/; do
        if [[ -e ${d}$name || -L ${d}$name ]]; then
            printf '%s' "${d}$name"
            return 0
        fi
    done
    return 1
}

# remove_empty_dirs DEST: remove the folders DEST was in, as far as they are now empty.
remove_empty_dirs() {
    local d
    d=$(dirname "$1")
    while [[ $d == "$HOME"/* && $d != "$CONF" && $d != "$HOME/Pictures" && $d != "$HOME/.local" && $d != "$HOME/.local/bin" ]]; do
        rmdir "$d" 2>/dev/null || break
        d=$(dirname "$d")
    done
}

uninstall() {
    local i dest backup
    local -a as
    log "Uninstall: removing only files that are still exact copies of this repo's files"
    if ((!YES && !DRY)); then
        ask "Remove the dwm-dotfiles files from this computer?" || exit 1
    fi
    for ((i = 0; i < ${#PAIRS[@]}; i += 2)); do
        remove_ours "${PAIRS[i + 1]}" "${PAIRS[i]}"
    done
    remove_ours /etc/X11/xorg.conf.d/40-libinput.conf "$SRC/X11/40-libinput.conf" sudo
    remove_ours /usr/share/xsessions/dwm.desktop "$SRC/X11/dwm.desktop" sudo
    if [[ -e /usr/local/bin/dwm || -e /usr/local/bin/dwmblocks ]]; then
        run sudo make -C "$SRC/dwm" uninstall
        run sudo make -C "$SRC/dwmblocks" uninstall
    fi

    for dest in "${REMOVED[@]}"; do
        ((DRY)) || remove_empty_dirs "$dest"
        backup=$(oldest_backup "$dest") || continue
        if ((DRY)) || ask "Restore your old $dest from the backup?"; then
            as=()
            [[ $dest == "$HOME"/* ]] || as=(sudo)
            run "${as[@]}" mkdir -p -- "$(dirname "$dest")"
            run "${as[@]}" cp -a -- "$backup" "$dest"
        fi
    done
    log "Done. ${#REMOVED[@]} file(s) removed. Packages (rofi, picom, dunst and the others) stay installed: remove them with your package manager if you want. Log out of dwm to finish."
}

main() {
    while (($#)); do
        case $1 in
            --dry-run) DRY=1 ;;
            --yes) YES=1 ;;
            --check) CHECK=1 ;;
            --firewall) FIREWALL=1 ;;
            --power) POWER=1 ;;
            --uninstall) UNINSTALL=1 ;;
            --dotfiles) DOTFILES=1 ;;
            -h|--help) usage; exit 0 ;;
            *) die "unknown option: $1 (see --help)" ;;
        esac
        shift
    done

    ((EUID != 0)) || die "run this as a normal user, not root"
    collect
    if ((UNINSTALL)); then
        uninstall
        exit
    fi
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

    other=$(other_network)
    if [[ -n $other ]]; then
        NM=0
        log "Network: this computer already uses $other. NetworkManager is NOT installed or turned on, so your network stays as it is. The Wi-Fi tray icon is not available."
    fi
    install_packages
    if ((NM)) && ! systemctl is-active --quiet NetworkManager 2>/dev/null; then
        run sudo systemctl enable --now NetworkManager || log "could not enable NetworkManager; enable it yourself"
    fi

    log "Creating the standard home folders"
    run xdg-user-dirs-update

    if ((FIREWALL)); then
        log "Turning on the firewall (incoming connections blocked)"
        run sudo ufw default deny incoming
        run sudo ufw default allow outgoing
        # Allow SSH first, so turning the firewall on cannot lock out a remote login.
        if [[ -x /usr/bin/sshd || -x /usr/sbin/sshd ]]; then
            run sudo ufw allow ssh
        fi
        run sudo ufw --force enable
        run sudo systemctl enable --now ufw
    else
        log "Firewall not changed (add --firewall to turn on ufw)"
    fi

    if ((POWER)); then
        log "Turning on tlp (laptop power saving). If you use power-profiles-daemon, remove it: the two do not work together"
        run sudo systemctl enable --now tlp || log "could not enable tlp; enable it yourself"
    else
        log "Power settings not changed (add --power to install and turn on tlp)"
    fi

    log "Building and installing dwm"
    run make -C "$SRC/dwm" clean
    run make -C "$SRC/dwm"
    run sudo make -C "$SRC/dwm" install

    log "Building and installing dwmblocks"
    run make -C "$SRC/dwmblocks" clean
    run make -C "$SRC/dwmblocks"
    run sudo make -C "$SRC/dwmblocks" install

    log "Copying configuration"
    local i
    for ((i = 0; i < ${#PAIRS[@]}; i += 2)); do
        if keep_personal "${PAIRS[i + 1]}" "${PAIRS[i]}"; then
            log "Kept your own ${PAIRS[i + 1]} (use --dotfiles to replace it)"
            continue
        fi
        put "${PAIRS[i]}" "${PAIRS[i + 1]}"
    done
    put "$SRC/X11/40-libinput.conf" /etc/X11/xorg.conf.d/40-libinput.conf sudo
    # A real copy, not a link: some login screens do not see linked session files.
    put "$SRC/X11/dwm.desktop" /usr/share/xsessions/dwm.desktop sudo

    if ((!DRY)); then
        verify || die "$FAIL check(s) failed, see above"
    fi
    if pgrep -x dwm >/dev/null; then
        log "Done. dwm is already running with the old setup. Close it with: pkill -x dwm, then start it again with: startx"
    else
        log "Done. Start dwm with: startx"
    fi
}

main "$@"
