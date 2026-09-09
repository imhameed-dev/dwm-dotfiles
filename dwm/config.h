/* See LICENSE file for copyright and license details. */
#include <X11/XF86keysym.h>
#include "polybar-height.h"

#define STR_HELPER(x) #x
#define STR(x) STR_HELPER(x)

/* ======================= APPEARANCE ======================= */
static const unsigned int borderpx = 1; /* border pixel of windows */
static const unsigned int snap = 32; /* snap pixel */
static const int showbar = 0; /* 0 means no bar */
static const int polybargap = POLYBAR_RESERVED_HEIGHT; /* external Polybar + intentional top/bottom breathing room */
static const int topbar = 1; /* 0 means bottom bar */
static const char *fonts[] = { "monospace:size=10" };
static const char dmenufont[] = "monospace:size=10";
static const char col_gray1[] = "#222222";
static const char col_gray2[] = "#444444";
static const char col_gray3[] = "#bbbbbb";
static const char col_gray4[] = "#eeeeee";
static const char col_cyan[] = "#005577";
static const char *colors[][3] = {
/* fg bg border */
[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
[SchemeSel] = { col_gray4, col_cyan, col_cyan },
};

/* ======================= TAGGING (WORKSPACES) ======================= */
static const char *tags[] = { "1", "2", "3", "4", "5" };

static const Rule rules[] = {
/* xprop(1):
* WM_CLASS(STRING) = instance, class
* WM_NAME(STRING) = title
*/
/* class instance title tags mask isfloating monitor */
{ "Gimp", NULL, NULL, 0, 1, -1 },
{ "Firefox", NULL, NULL, 1 << 0, 0, -1 },
};

/* ======================= LAYOUTS ======================= */
static const float mfact = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster = 1; /* number of clients in master area */
static const int resizehints = 1; /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
static const int refreshrate = 120; /* refresh rate (per second) for client move/resize */

static const Layout layouts[] = {
/* symbol arrange function */
{ "[]=", tile }, /* first entry is default */
{ "><>", NULL }, /* no layout function means floating behavior */
{ "[M]", monocle },
};

/* ======================= KEY DEFINITIONS / MACROS ======================= */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
{ MODKEY, KEY, view, {.ui = 1 << TAG} }, \
{ MODKEY|ControlMask, KEY, toggleview, {.ui = 1 << TAG} }, \
{ MODKEY|ShiftMask, KEY, tag, {.ui = 1 << TAG} }, \
{ MODKEY|ControlMask|ShiftMask, KEY, toggletag, {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* ======================= COMMANDS (programs launched by keys) ======================= */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
static const char *termcmd[] = { "alacritty", NULL };
static const char *roficmd[] = { "rofi", "-show", "drun", NULL };
static const char *browsercmd[] = {
    "/bin/sh", "-c",
    "if command -v firefox >/dev/null 2>&1; then "
    "exec firefox; "
    "elif command -v firefox-esr >/dev/null 2>&1; then "
    "exec firefox-esr; "
    "else printf '%s\n' 'Firefox is not installed' >&2; exit 1; fi",
    NULL
};
static const char *thunarcmd[] = { "thunar", NULL };
static const char *powermenucmd[] = { "/bin/sh", "-c", "$HOME/.config/rofi/scripts/powermenu.sh", NULL };
static const char *autostartcmd[] = { "/bin/sh", "-c", "$HOME/.dwm-autostart.sh", NULL };
static const char *wallpapermenucmd[] = { "/bin/sh", "-c", "$HOME/.config/rofi/scripts/wallpaper-menu.sh", NULL };

static const Key keys[] = {
/* modifier key function argument */

/* ---------- Applications ---------- */
{ MODKEY, XK_Return, spawn, {.v = termcmd } }, /* Super+Enter -> Alacritty */
{ MODKEY, XK_space, spawn, {.v = roficmd } }, /* Super+Space -> Rofi */
{ MODKEY, XK_w, spawn, {.v = wallpapermenucmd } }, /* Super+W -> wallpaper */
{ MODKEY, XK_b, spawn, {.v = browsercmd } }, /* Super+B -> Browser */
{ MODKEY, XK_e, spawn, {.v = thunarcmd } }, /* Super+E -> Thunar */
{ MODKEY|ShiftMask, XK_s, spawn, {.v = powermenucmd } }, /* Super+Shift+S -> Power menu */
{ MODKEY, XK_p, spawn, {.v = dmenucmd } }, /* Super+P -> dmenu */

/* ---------- Volume & Media Keys ---------- */
{ 0, XF86XK_AudioRaiseVolume, spawn, SHCMD("pactl set-sink-volume @DEFAULT_SINK@ +5%") },
{ 0, XF86XK_AudioLowerVolume, spawn, SHCMD("pactl set-sink-volume @DEFAULT_SINK@ -5%") },
{ 0, XF86XK_AudioMute, spawn, SHCMD("pactl set-sink-mute @DEFAULT_SINK@ toggle") },

/* ---------- Brightness Control   ----------- */
{ 0, XF86XK_MonBrightnessUp, spawn, SHCMD("brightnessctl set +10%") },
{ 0, XF86XK_MonBrightnessDown, spawn, SHCMD("brightnessctl set 10%-") },

/* ---------- Window Focus & Management ---------- */
{ MODKEY, XK_j, focusstack, {.i = +1 } },
{ MODKEY, XK_k, focusstack, {.i = -1 } },
{ MODKEY, XK_q, killclient, {0} }, /* Super+Q -> Close window */
{ MODKEY|ShiftMask, XK_Return, zoom, {0} }, /* Super+Shift+Enter -> swap with master */
{ MODKEY|ShiftMask, XK_space, togglefloating, {0} },
{ MODKEY, XK_Tab, view, {0} },
{ MODKEY, XK_comma, focusmon, {.i = -1 } },
{ MODKEY, XK_period, focusmon, {.i = +1 } },
{ MODKEY|ShiftMask, XK_comma, tagmon, {.i = -1 } },
{ MODKEY|ShiftMask, XK_period, tagmon, {.i = +1 } },

/* ---------- Layout Control ---------- */
{ MODKEY, XK_i, incnmaster, {.i = +1 } },
{ MODKEY, XK_d, incnmaster, {.i = -1 } },
{ MODKEY, XK_h, setmfact, {.f = -0.05} },
{ MODKEY, XK_l, setmfact, {.f = +0.05} },
{ MODKEY, XK_t, setlayout, {.v = &layouts[0]} }, /* tiled layout */
{ MODKEY, XK_f, setlayout, {.v = &layouts[1]} }, /* floating layout */
{ MODKEY, XK_m, setlayout, {.v = &layouts[2]} }, /* monocle layout */
{ MODKEY, XK_o, setlayout, {0} }, /* Super+O -> cycle layout */

/* ---------- Workspaces (Tags) ---------- */
{ MODKEY, XK_0, view, {.ui = ~0 } },
{ MODKEY|ShiftMask, XK_0, tag, {.ui = ~0 } },
TAGKEYS( XK_1, 0)
TAGKEYS( XK_2, 1)
TAGKEYS( XK_3, 2)
TAGKEYS( XK_4, 3)
TAGKEYS( XK_5, 4)

/* ---------- DWM Control ---------- */
{ MODKEY|ShiftMask, XK_b, togglebar, {0} }, /* Super+Shift+B -> toggle bar */
{ MODKEY|ShiftMask, XK_r, restart, {0} }, /* Super+Shift+R -> restart DWM */
{ MODKEY|ShiftMask, XK_q, quit, {0} }, /* Super+Shift+Q -> quit DWM */
};

/* ======================= MOUSE BUTTONS ======================= */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
/* click event mask button function argument */
{ ClkLtSymbol, 0, Button1, setlayout, {0} },
{ ClkLtSymbol, 0, Button3, setlayout, {.v = &layouts[2]} },
{ ClkWinTitle, 0, Button2, zoom, {0} },
{ ClkStatusText, 0, Button2, spawn, {.v = termcmd } },
{ ClkClientWin, MODKEY, Button1, movemouse, {0} },
{ ClkClientWin, MODKEY, Button2, togglefloating, {0} },
{ ClkClientWin, MODKEY, Button3, resizemouse, {0} },
{ ClkTagBar, 0, Button1, view, {0} },
{ ClkTagBar, 0, Button3, toggleview, {0} },
{ ClkTagBar, MODKEY, Button1, tag, {0} },
{ ClkTagBar, MODKEY, Button3, toggletag, {0} },
};
