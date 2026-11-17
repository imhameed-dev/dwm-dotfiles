/* See LICENSE file for copyright and license details. */
#include <X11/XF86keysym.h>

/* ======================= APPEARANCE ======================= */
static const unsigned int borderpx = 1; /* border pixel of windows */
static const unsigned int snap = 32; /* snap pixel */
static const unsigned int systraypinning = 0; /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft = 0; /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2; /* systray spacing */
static const int systraypinningfailfirst = 1; /* 1: if pinning fails, display systray on the first monitor, 0: last monitor */
static const int showsystray = 1; /* 0 means no systray */
static const int showbar = 1; /* 0 means no bar */
static const unsigned int outergap = 8; /* gap between tiled windows and the screen's left/right/bottom edges */
static const int topbar = 1; /* 0 means bottom bar */
static const char *fonts[] = { "monospace:size=10" };
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
/*
 * HOW TO CHANGE A SHORTCUT
 *   Every line in keys[] below has 4 parts:
 *       { modifier,  key,  action,  argument },
 *   - modifier: MODKEY is the Super (Windows) key. Add more with |, for example
 *               MODKEY|ShiftMask is Super+Shift. A 0 means no modifier.
 *   - key:      XK_a to XK_z, XK_1, XK_Return, XK_space ... (list: /usr/include/X11/keysymdef.h)
 *   - action:   spawn starts a program, other names are dwm actions (killclient, view ...).
 *   - argument: for spawn, the command (see COMMANDS below).
 *   After you edit this file, rebuild and restart dwm:
 *       make -C dwm clean && make -C dwm && sudo make -C dwm install
 *       then press Super+Shift+R.
 */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
{ MODKEY,                    KEY, view,       {.ui = 1 << TAG} }, \
{ MODKEY|ControlMask,        KEY, toggleview, {.ui = 1 << TAG} }, \
{ MODKEY|ShiftMask,          KEY, tag,        {.ui = 1 << TAG} }, \
{ MODKEY|ControlMask|ShiftMask, KEY, toggletag, {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* ======================= COMMANDS (programs launched by keys) ======================= */
static const char *termcmd[]          = { "xfce4-terminal", NULL };
static const char *roficmd[]          = { "rofi", "-show", "drun", NULL };
static const char *browsercmd[]       = { "brave-origin", NULL };   /* change this to use another browser */
static const char *thunarcmd[]        = { "thunar", NULL };
static const char *powermenucmd[]     = { "/bin/sh", "-c", "bash $HOME/.config/rofi/scripts/powermenu.sh", NULL };
static const char *autostartcmd[]     = { "/bin/sh", "-c", "sh $HOME/.autostart.sh", NULL };
static const char *wallpapermenucmd[] = { "/bin/sh", "-c", "bash $HOME/.config/rofi/scripts/wallpaper-menu.sh", NULL };

/* ======================= KEYBOARD SHORTCUTS ======================= */
/* "Super" below means the Windows key. */
static const Key keys[] = {
/* modifier           key                         action          argument                       what it does */

/* ---------- Applications ---------- */
{ MODKEY,             XK_Return,                  spawn,          {.v = termcmd } },             /* Super+Enter        terminal */
{ MODKEY,             XK_space,                   spawn,          {.v = roficmd } },             /* Super+Space        app launcher (Rofi) */
{ MODKEY,             XK_w,                       spawn,          {.v = wallpapermenucmd } },    /* Super+W            wallpaper menu */
{ MODKEY,             XK_b,                       spawn,          {.v = browsercmd } },          /* Super+B            browser (Brave Origin) */
{ MODKEY,             XK_e,                       spawn,          {.v = thunarcmd } },           /* Super+E            files (Thunar) */
{ MODKEY|ShiftMask,   XK_s,                       spawn,          {.v = powermenucmd } },        /* Super+Shift+S      power menu */

/* ---------- Volume and media keys (the bar refreshes through pkill -RTMIN+10 dwmblocks) ---------- */
{ 0,                  XF86XK_AudioRaiseVolume,    spawn,          SHCMD("pactl set-sink-volume @DEFAULT_SINK@ +5%; pkill -RTMIN+10 dwmblocks") },    /* volume up */
{ 0,                  XF86XK_AudioLowerVolume,    spawn,          SHCMD("pactl set-sink-volume @DEFAULT_SINK@ -5%; pkill -RTMIN+10 dwmblocks") },    /* volume down */
{ 0,                  XF86XK_AudioMute,           spawn,          SHCMD("pactl set-sink-mute @DEFAULT_SINK@ toggle; pkill -RTMIN+10 dwmblocks") },   /* mute */

/* ---------- Brightness ---------- */
{ 0,                  XF86XK_MonBrightnessUp,     spawn,          SHCMD("brightnessctl set +10%") },                       /* brightness up */
{ 0,                  XF86XK_MonBrightnessDown,   spawn,          SHCMD("brightnessctl --min-value=1 set 10%-") },         /* brightness down */

/* ---------- Windows ---------- */
{ MODKEY,             XK_j,                       focusstack,     {.i = +1 } },                  /* Super+J            next window */
{ MODKEY,             XK_k,                       focusstack,     {.i = -1 } },                  /* Super+K            previous window */
{ MODKEY,             XK_q,                       killclient,     {0} },                         /* Super+Q            close window */
{ MODKEY|ShiftMask,   XK_Return,                  zoom,           {0} },                         /* Super+Shift+Enter  swap with the main window */
{ MODKEY|ShiftMask,   XK_space,                   togglefloating, {0} },                         /* Super+Shift+Space  float or tile the window */
{ MODKEY,             XK_Tab,                     view,           {0} },                         /* Super+Tab          previous workspace */
{ MODKEY,             XK_comma,                   focusmon,       {.i = -1 } },                  /* Super+,            previous monitor */
{ MODKEY,             XK_period,                  focusmon,       {.i = +1 } },                  /* Super+.            next monitor */
{ MODKEY|ShiftMask,   XK_comma,                   tagmon,         {.i = -1 } },                  /* Super+Shift+,      move window to previous monitor */
{ MODKEY|ShiftMask,   XK_period,                  tagmon,         {.i = +1 } },                  /* Super+Shift+.      move window to next monitor */

/* ---------- Layout ---------- */
{ MODKEY,             XK_i,                       incnmaster,     {.i = +1 } },                  /* Super+I            more windows in the main area */
{ MODKEY,             XK_d,                       incnmaster,     {.i = -1 } },                  /* Super+D            fewer windows in the main area */
{ MODKEY,             XK_h,                       setmfact,       {.f = -0.05} },                /* Super+H            shrink the main area */
{ MODKEY,             XK_l,                       setmfact,       {.f = +0.05} },                /* Super+L            grow the main area */
{ MODKEY,             XK_t,                       setlayout,      {.v = &layouts[0]} },          /* Super+T            tiled layout */
{ MODKEY,             XK_f,                       setlayout,      {.v = &layouts[1]} },          /* Super+F            floating layout */
{ MODKEY,             XK_m,                       setlayout,      {.v = &layouts[2]} },          /* Super+M            monocle layout (one window full screen) */
{ MODKEY,             XK_o,                       setlayout,      {0} },                         /* Super+O            switch between layouts */

/* ---------- Workspaces (Super+1..5 go there, add Shift to move the window there) ---------- */
{ MODKEY,             XK_0,                       view,           {.ui = ~0 } },                 /* Super+0            show all workspaces */
{ MODKEY|ShiftMask,   XK_0,                       tag,            {.ui = ~0 } },                 /* Super+Shift+0      window on all workspaces */
TAGKEYS(                                          XK_1,                        0)
TAGKEYS(                                          XK_2,                        1)
TAGKEYS(                                          XK_3,                        2)
TAGKEYS(                                          XK_4,                        3)
TAGKEYS(                                          XK_5,                        4)

/* ---------- dwm itself ---------- */
{ MODKEY|ShiftMask,   XK_b,                       togglebar,      {0} },                         /* Super+Shift+B      show or hide the bar */
{ MODKEY|ShiftMask,   XK_r,                       restart,        {0} },                         /* Super+Shift+R      restart dwm */
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
