/* Each row is one segment of the bar's status text, left to right in the
 * order listed below. interval=0 means "never runs on a timer, only on
 * its signal" (see dwmblocks.c's header comment). delim separates segments. */
static char delim = '|';

static const Block blocks[] = {
	/* icon	command                                                                 interval (s)	signal */
	/* Volume: signal-only (10), sent by the volume/mute keybinds in dwm/config.h */
	{"",	"pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -q yes && printf 'Vol Mute' || printf 'Vol %s' $(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5; exit}')",	0,	10},
	/* Battery: first BAT* found (any laptop); prints nothing if there is none. Uses shell builtins only. */
	{"",	"for b in /sys/class/power_supply/BAT*; do read c < $b/capacity || exit 0; read s < $b/status; case $s in Charging) s=+;; *) s=;; esac; printf 'Bat %s%%%s' $c $s; break; done",	60,	0},
	/* Date/time: 12-hour clock, weekday, month, day */
	{"",	"date '+%-I:%M %p %a, %b %d'",	30,	0},
};
