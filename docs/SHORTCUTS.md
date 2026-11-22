# Shortcuts

Super is the Windows key. Every shortcut is defined in `dwm/config.h`. To change one, see "How to change a shortcut" at the end.

## Programs

| Keys | What it does |
| --- | --- |
| Super+Enter | Open the terminal (xfce4-terminal) |
| Super+Space | Open the app launcher (Rofi). Type to search, press Enter to start |
| Super+B | Open the browser (Brave Origin) |
| Super+E | Open the file manager (Thunar) |
| Super+V | Open the volume and sound output picker (pavucontrol) |
| Super+W | Open the wallpaper menu. Pick a picture to change the wallpaper |
| Super+Shift+S | Open the power menu: Lock, Sleep, Log out, Reboot, Shut down |

## Windows

| Keys | What it does |
| --- | --- |
| Super+J | Focus the next window |
| Super+K | Focus the previous window |
| Super+Q | Close the focused window |
| Super+Shift+Enter | Swap the focused window with the main (big) window |
| Super+Shift+Space | Make the window float (free to move and resize), or tile it again |
| Super+, and Super+. | Focus the previous or next monitor (only matters with two or more monitors) |
| Super+Shift+, and Super+Shift+. | Send the window to the previous or next monitor |
| Super+Shift+M | Set up all screens: turns on every connected monitor side by side (laptop screen first) and turns off unplugged ones. Press it after plugging in or unplugging a monitor |

## Layout

| Keys | What it does |
| --- | --- |
| Super+T | Tiled layout: windows side by side, one main window on the left |
| Super+F | Floating layout: windows overlap and you place them yourself |
| Super+M | Monocle layout: one window fills the screen |
| Super+O | Switch back to the layout you used before |
| Super+H | Make the main window narrower |
| Super+L | Make the main window wider |
| Super+I | Put one more window in the main area |
| Super+D | Put one less window in the main area |

## Workspaces (there are 5)

| Keys | What it does |
| --- | --- |
| Super+1 to Super+5 | Go to that workspace |
| Super+Shift+1 to 5 | Move the focused window to that workspace |
| Super+Ctrl+1 to 5 | Also show that workspace at the same time as this one (press again to remove it) |
| Super+Ctrl+Shift+1 to 5 | Show the focused window on that workspace too (press again to remove it) |
| Super+Tab | Go back to the previous workspace |
| Super+0 | Show the windows of all workspaces together |
| Super+Shift+0 | Show the focused window on all workspaces |

## dwm itself

| Keys | What it does |
| --- | --- |
| Super+Shift+R | Restart dwm. Use it after you rebuild dwm. Your windows stay open |
| Super+Shift+B | Hide or show the top bar |

There is no key that quits dwm. To log out, use the power menu (Super+Shift+S).

## Keyboard keys

| Key | What it does |
| --- | --- |
| Volume up, volume down | Change the volume by 5% (the bar updates at once) |
| Mute | Turn the sound off or on |
| Play/pause, next, previous | Control the playing music or video (`playerctl`; works with Brave and other players that support it) |
| Brightness up, brightness down | Change the screen brightness by 10%. It never goes fully black |
| Print | Screenshot of all screens, saved in `~/Pictures/screenshots` (a notice shows the file name) |
| Shift+Print | Screenshot of a box you drag with the mouse (Esc cancels) |

## Mouse

| Action | What it does |
| --- | --- |
| Left-click a workspace number in the bar | Go to that workspace |
| Right-click a workspace number | Show that workspace together with the current one |
| Super+click a workspace number | Move the focused window there |
| Super+right-click a workspace number | Show the focused window on that workspace too |
| Left-click the layout symbol (for example `[]=`) | Switch back to the previous layout |
| Right-click the layout symbol | Monocle layout |
| Middle-click the window title in the bar | Swap that window with the main window |
| Middle-click the status text (volume, battery, time) | Open a terminal |
| Super+drag with the left button | Move a window (it becomes floating) |
| Super+drag with the right button | Resize a window (it becomes floating) |
| Super+middle-click on a window | Float or tile the window |

## How to change a shortcut

1. Open `dwm/config.h` and find the line in the `keys[]` list. Each line has four parts: modifier, key, action, argument. `MODKEY` is Super, and you add more with `|` (for example `MODKEY|ShiftMask`).
2. Change the key name (for example `XK_b` to `XK_g`). Key names are in `/usr/include/X11/keysymdef.h`.
3. Rebuild, then restart dwm:

```bash
make -C dwm clean && make -C dwm && sudo make -C dwm install
```

Then press Super+Shift+R. To run a different program, change the command in the `COMMANDS` section at the top of the shortcut list (for example `browsercmd`).
