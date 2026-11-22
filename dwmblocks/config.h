/* HOW TO CHANGE THE BAR: add a segment by copying a row below, remove one by
 * deleting its row, change how often it updates in the interval column.
 * Then rebuild and restart:
 *   make -C dwmblocks clean && make -C dwmblocks && sudo make -C dwmblocks install
 *   pkill -x dwmblocks   (then press Super+Shift+R: dwm starts it again)
 *
 * Each row is one segment of the bar's status text, left to right in the
 * order listed below. interval=0 means "never runs on a timer, only on
 * its signal" (see dwmblocks.c's header comment). delim separates segments. */
static char delim = '|';

static const Block blocks[] = {
	/* icon	command                                                                 interval (s)	signal */
	/* Volume: signal-only (10), sent by the volume/mute keybinds in dwm/config.h. scripts/volume-status.sh (installed as ~/.local/bin/volume-status) prints an icon and the percent. */
	{"",	"$HOME/.local/bin/volume-status 2>/dev/null",	0,	10},
	/* Battery: scripts/battery-alert.sh (installed as ~/.local/bin/battery-alert). It prints a battery icon and "85%", prints nothing on a PC, and shows a notice at 15% and 5%. */
	{"",	"$HOME/.local/bin/battery-alert 2>/dev/null",	60,	0},
	/* Date/time: 12-hour clock, weekday, month, day */
	{"",	"date '+%-I:%M %p %a, %b %d'",	30,	0},
};
