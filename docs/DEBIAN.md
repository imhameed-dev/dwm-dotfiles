# Debian-family Linux

The installer uses APT and Debian-family package names separately from Arch.

Supported targets include Debian, Ubuntu, Linux Mint, Pop!_OS, elementary OS, Zorin OS, Kali, and other systems whose `ID_LIKE` identifies them as Debian-family systems and whose repositories provide the required packages.

Audio uses PipeWire, `pipewire-pulse`, and WirePlumber. The desktop uses `network-manager-gnome` for the NetworkManager tray applet.

Firefox is installed automatically. On Debian-family systems the installer uses `firefox` when available and falls back to `firefox-esr`; if neither is available from the configured repositories, installation stops rather than leaving a broken browser shortcut.


The installer enables and starts the NetworkManager service when systemd is available. It does not remove packages during uninstall.
