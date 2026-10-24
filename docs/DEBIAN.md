# Debian, Ubuntu and similar

The installer uses APT on Debian and Debian-based systems. It detects them from `/etc/os-release`.

**How well tested:** this setup was first built on Debian 13 and is now used daily on Arch Linux. Debian-based systems should work, but they are tested less. If a package name does not exist in your release, the installer stops and tells you which one.

Sound uses PipeWire and WirePlumber. Wi-Fi uses NetworkManager with a tray icon (`network-manager-gnome`).

Browser: Firefox is installed (`firefox`, or `firefox-esr` if that is all your release has). If you already use Brave, Super+B opens it instead.

The installer turns on NetworkManager and never removes packages.
