/* See LICENSE file for copyright and license details. */

#include <X11/XF86keysym.h>
#define OPAQUE 0xffU

#define XF86AudioPrev   0x1008FF16
#define XF86AudioPlay   0x1008FF14
#define XF86AudioNext   0x1008FF17
#define XF86AudioStop   0x1008FF15

/* appearance */
static const unsigned int borderpx     = 3;   /* border pixel of windows */
static const unsigned int tabModKey    = 0x40;
static const unsigned int tabCycleKey  = 0x17;
static const unsigned int snap         = 32;  /* snap pixel */
static const int swallowfloating       = 0;   /* 1 means swallow floating windows by default */

static const unsigned int gappih       = 5;   /* horiz inner gap between windows */
static const unsigned int gappiv       = 5;   /* vert inner gap between windows */
static const unsigned int gappoh       = 5;   /* horiz outer gap between windows and screen edge */
static const unsigned int gappov       = 5;   /* vert outer gap between windows and screen edge */
static const int smartgaps             = 0;   /* 1 means no outer gap when there is only one window */

static const int showbar               = 1;   /* 0 means no bar */
static const int topbar                = 1;   /* 0 means bottom bar */
static const char *fonts[]             = { "JetBrainsMono Nerd Fonts:size=11" };
static const char dmenufont[]          = "monospace:size=10";

/* colors - Catppuccin Mocha */
static const char col_bg[]             = "#1e1e2e";
static const char col_fg[]             = "#cdd6f4";

static const char col_tag_fg[]         = "#1e1e2e"; /* dark text for selected tag */
static const char col_tag_bg[]         = "#89b4fa"; /* bluish background for selected tag */

static const char col_border_norm[]    = "#313244"; /* inactive window border */
static const char col_text_norm[]      = "#a6adc8"; /* inactive window text */

static const char col_border_sel[]     = "#89b4fa"; /* active (selected) border */
static const char col_text_sel[]       = "#cdd6f4"; /* active text */

/* dwm color schemes */
static const char *colors[][3] = {
	/*                fg              bg        border          */
	[SchemeNorm]    = { col_text_norm, col_bg,   col_border_norm },
	[SchemeSel]     = { col_text_sel,  col_bg,   col_border_sel  },
	[SchemeTagNorm] = { col_text_norm, col_bg,   col_border_norm },
	[SchemeTagSel]  = { col_tag_fg,    col_tag_bg, col_border_sel },
};

/* tagging */
static const char *tags[]           = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };
static const char *defaulttagapps[] = { "st", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };

static const Rule rules[] = {
	/* class      instance  title           tags mask  isfloating  isterminal  noswallow  monitor */
	{ "Gimp",     NULL,     NULL,           0,         1,          0,           0,        -1 },
	{ "Firefox",  NULL,     NULL,      1 << 8,         0,          0,          -1,        -1 },
	{ "Alacritty",NULL,     NULL,           0,         0,          1,           0,        -1 },
	{ "Lf",       NULL,     NULL,           0,         0,          1,           0,        -1 },
	{ NULL,       NULL, "Event Tester",     0,         0,          0,           1,        -1 }, /* xev */
};

/* window following */
#define WFACTIVE   '>'
#define WFINACTIVE ' '
#define WFDEFAULT  WFINACTIVE

/* audio control */
static const char *upvol[]   = { "/usr/bin/pactl", "set-sink-volume", "0", "+10%", NULL };
static const char *downvol[] = { "/usr/bin/pactl", "set-sink-volume", "0", "-10%", NULL };
static const char *mutevol[] = { "/usr/bin/pactl", "set-sink-mute",   "0", "toggle", NULL };

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

#define FORCE_VSPLIT 1 /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"
#include "tatami.c"

static const Layout layouts[] = {
	/* symbol     arrange function */
    { "[ T ]",      tile },                  /* default */
    { "[ F ]",      NULL },                  /* floating */
    { "[ M ]",      monocle },
    { "[ S ]",      spiral },
    { "[ D ]",      dwindle },
    { "[ DC ]",      deck },
    { "[ BS ]",      bstack },
    { "[ BSH ]",      bstackhoriz },
    { "[ G ]",      grid },
    { "[ NG ]",      nrowgrid },
    { "[ HG ]",      horizgrid },
    { "[ GG ]",      gaplessgrid },
    { "[ CMS ]",      centeredmaster },
    { "[ CFM ]",      centeredfloatingmaster },
    { "[ TTM ]",      tatami },
	{ NULL ,       NULL },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY, view,       {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY, toggleview, {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY, tag,        {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY, toggletag,  {.ui = 1 << TAG} },

#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0";
static const char *dmenucmd[] = {
	"dmenu_run", "-m", dmenumon, "-fn", dmenufont,
	"-nb", col_bg, "-nf", col_text_norm,
	"-sb", col_border_sel, "-sf", col_text_sel,
	NULL
};

static const char *termcmd[]   = { "st", NULL };
static const char *rofi[]      = { "rofi", "-show", "drun", "-theme", "~/.config/rofi/config.rasi", NULL };
static const char *rofi_calc[] = { "rofi", "-show", "calc", "-theme", "~/.config/rofi/config.rasi", NULL };
static const char *chromium[]  = { "chromium", NULL };
static const char *firefox_developer_edition[] = { "firefox-developer-edition", NULL };
static const char *mullvad_browser[] = { "mullvad-browser", NULL };
static const char *nvim[]      = { "st", "-e", "nvim", NULL };

#include "movestack.c"
static const Key keys[] = {
	/* modifier                  key        function         argument */
	{ MODKEY|Mod1Mask,           XK_F5,     spawn,           SHCMD("~/.local/bin/scripts/refresh-dwmblocks") },
	{ MODKEY|ShiftMask,          XK_p,      spawn,           SHCMD("simple-mtpfs ~/Phone && pkill -RTMIN+8 dwmblocks && st -e lf ~/Phone") },
	{ MODKEY|ControlMask,        XK_p,      spawn,           SHCMD("fusermount -u ~/Phone && pkill -RTMIN+8 dwmblocks") },
	{ MODKEY,                    XK_u,      spawn,           SHCMD("~/.local/bin/scripts/usb-toggle.sh mount") },
	{ MODKEY|ShiftMask,          XK_u,      spawn,           SHCMD("~/.local/bin/scripts/usb-toggle.sh unmount") },
	{ MODKEY|ShiftMask,          XK_F1,     spawn,           SHCMD("st -e lfub /run/media/$USER") },

	/* Media Control */
	{ 0, XF86AudioStop,          spawn,     SHCMD("playerctl stop") },
	{ 0, XF86AudioPrev,          spawn,     SHCMD("playerctl previous") },
	{ 0, XF86AudioPlay,          spawn,     SHCMD("playerctl play-pause") },
	{ 0, XF86AudioNext,          spawn,     SHCMD("playerctl next") },

	/* Power & HDD */
	{ MODKEY|ShiftMask,          XK_Escape, spawn,           SHCMD("~/.local/bin/scripts/powermenu.sh") },
	{ MODKEY|Mod1Mask,           XK_v,      spawn,           SHCMD("~/.local/bin/scripts/sb-hdd-toggle") },
	{ MODKEY,                    XK_F5,     spawn,           SHCMD("~/.local/bin/scripts/hdd_mounting_ctl/toggle_hdd.sh mount backup") },
	{ MODKEY|ShiftMask,          XK_F5,     spawn,           SHCMD("~/.local/bin/scripts/hdd_mounting_ctl/toggle_hdd.sh unmount backup") },
	{ MODKEY,                    XK_F6,     spawn,           SHCMD("~/.local/bin/scripts/hdd_mounting_ctl/toggle_hdd.sh mount movies1") },
	{ MODKEY|ShiftMask,          XK_F6,     spawn,           SHCMD("~/.local/bin/scripts/hdd_mounting_ctl/toggle_hdd.sh unmount movies1") },
	{ MODKEY,                    XK_F7,     spawn,           SHCMD("~/.local/bin/scripts/hdd_mounting_ctl/toggle_hdd.sh mount movies2") },
	{ MODKEY|ShiftMask,          XK_F7,     spawn,           SHCMD("~/.local/bin/scripts/hdd_mounting_ctl/toggle_hdd.sh unmount movies2") },

	/* File Managers */
	{ MODKEY,                    XK_f,      spawn,           SHCMD("st -e lfub ~") },
	{ MODKEY,                    XK_F2,     spawn,           SHCMD("st -e lfub '/run/media/trinity3/Backup_Files'") },
	{ MODKEY,                    XK_F3,     spawn,           SHCMD("st -e lfub '/run/media/trinity3/Movies_Main'") },
	{ MODKEY,                    XK_F4,     spawn,           SHCMD("st -e lfub '/run/media/trinity3/Movies_Extension'") },

	/* Volume */
	{ 0, XF86XK_AudioLowerVolume, spawn,    {.v = downvol } },
	{ 0, XF86XK_AudioMute,        spawn,    {.v = mutevol } },
	{ 0, XF86XK_AudioRaiseVolume, spawn,    {.v = upvol   } },

    /* rmpc-mpv music player togglee */
    { MODKEY|ShiftMask,           XK_m,     spawn,          SHCMD("~/.local/bin/scripts/mpd-rmpc.sh") },

	/* Cycle Layout */
	{ MODKEY|ControlMask,         XK_Left,  cyclelayout,     {.i = -1 } },
	{ MODKEY|ControlMask,         XK_Right, cyclelayout,     {.i = +1 } },

	/* Cycle Tag */
	{ MODKEY|ShiftMask,           XK_Left,  cycleview,       {1} },
	{ MODKEY|ShiftMask,           XK_Right, cycleview,       {0} },

	/* Cycle Monitor */
	{ MODKEY|Mod1Mask,            XK_Left,  focusmon,        {.i = -1 } },
	{ MODKEY|Mod1Mask,            XK_Right, focusmon,        {.i = +1 } },

	/* Cycle Windows */
	{ MODKEY,                     XK_Left,  focusstack,      {.i = -1 } },
	{ MODKEY,                     XK_Right, focusstack,      {.i = +1 } },

	/* Move Window on Monitor */
	{ MODKEY|Mod1Mask|ShiftMask,  XK_Left,  movestack,       {.i = -1 } },
	{ MODKEY|Mod1Mask|ShiftMask,  XK_Right, movestack,       {.i = +1 } },

	/* Move Window Across Monitors */
	{ MODKEY|ShiftMask|ControlMask, XK_Left, tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask|ControlMask, XK_Right,tagmon,         {.i = +1 } },

	/* Scratchpad */
	{ MODKEY,                     XK_minus, scratchpad_show,  {0} },
	{ MODKEY|ShiftMask,           XK_minus, scratchpad_hide,  {0} },
	{ MODKEY,                     XK_equal, scratchpad_remove,{0} },

    /* screenshot keybindings */
    { MODKEY,                     XK_x,     spawn, SHCMD("st -e ~/.local/bin/scripts/screenshot.sh") },
    { MODKEY|ShiftMask,           XK_x,     spawn, SHCMD("st -e ~/.local/bin/scripts/screenshot.sh -s") },
    { MODKEY|Mod1Mask,            XK_x,     spawn, SHCMD("st -e ~/.local/bin/scripts/recorder.sh") },            /* for recording screen */

    /* finding files and opening in neovim */


    /* spawning btop */
    { MODKEY|Mod1Mask,            XK_b,     spawn,           SHCMD("st -e btop") },

	/* Vanity Gaps */
	{ MODKEY|ShiftMask,           XK_h,     setcfact,        {.f = +0.25} },
	{ MODKEY|ShiftMask,           XK_l,     setcfact,        {.f = -0.25} },
	{ MODKEY|ShiftMask,           XK_o,     setcfact,        {.f =  0.00} },
	{ MODKEY|Mod1Mask,            XK_u,     incrgaps,        {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,  XK_u,     incrgaps,        {.i = -1 } },
	{ MODKEY|Mod1Mask,            XK_i,     incrigaps,       {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,  XK_i,     incrigaps,       {.i = -1 } },
	{ MODKEY|Mod1Mask,            XK_o,     incrogaps,       {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,  XK_o,     incrogaps,       {.i = -1 } },
	{ MODKEY|Mod1Mask,            XK_6,     incrihgaps,      {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,  XK_6,     incrihgaps,      {.i = -1 } },
	{ MODKEY|Mod1Mask,            XK_7,     incrivgaps,      {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,  XK_7,     incrivgaps,      {.i = -1 } },
	{ MODKEY|Mod1Mask,            XK_8,     incrohgaps,      {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,  XK_8,     incrohgaps,      {.i = -1 } },
	{ MODKEY|Mod1Mask,            XK_9,     incrovgaps,      {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,  XK_9,     incrovgaps,      {.i = -1 } },
	{ MODKEY|Mod1Mask,            XK_0,     togglegaps,      {0} },
	{ MODKEY|Mod1Mask|ShiftMask,  XK_0,     defaultgaps,     {0} },

	/* Default Applications */
	{ MODKEY,                     XK_s,     spawndefault,    {0} },

	/* Fullscreen */
	{ MODKEY|ControlMask,         XK_f,     fullscreen,      {0} },
    
    /* Toggle Follow */
	{ MODKEY|ShiftMask,           XK_f,     togglefollow,    {0} },

	/* Hidden tags */
   	{ MODKEY,                     XK_v,     togglehidevacant,{0} },

	/* Apps */
	{ MODKEY|ControlMask,         XK_w,     spawn,           {.v = mullvad_browser } },
	{ MODKEY|ShiftMask,           XK_w,     spawn,           {.v = firefox_developer_edition } },
	{ MODKEY,                     XK_w,     spawn,           {.v = chromium } },
	{ MODKEY,                     XK_g,     spawn,           {.v = dmenucmd } },
	{ MODKEY,                     XK_d,     spawn,           {.v = rofi } },
	{ MODKEY,                     XK_c,     spawn,           {.v = rofi_calc } },
	{ MODKEY,                     XK_Return,spawn,           {.v = termcmd } },
	{ MODKEY|ShiftMask,           XK_Return,spawn,           {.v = nvim } },
	{ MODKEY|Mod1Mask,            XK_Return,spawn,           SHCMD("st -e ~/.local/bin/scripts/tmux-sessionizer") },
	{ MODKEY|ShiftMask,           XK_n,     spawn,           SHCMD("st -e ~/.local/bin/scripts/zoxide_openfiles_nvim.sh") },
	{ MODKEY|ControlMask,         XK_n,     spawn,           SHCMD("st -e ~/.local/bin/scripts/fzf_listoldfiles.sh") },


	/* Window Management */
	{ MODKEY,                     XK_b,     togglebar,       {0} },
	{ MODKEY,                     XK_i,     incnmaster,      {.i = +1 } },
	{ MODKEY,                     XK_p,     incnmaster,      {.i = -1 } },
	{ MODKEY,                     XK_h,     setmfact,        {.f = -0.05} },
	{ MODKEY,                     XK_l,     setmfact,        {.f = +0.05} },
	{ MODKEY,                     XK_z,     zoom,            {0} },
	{ MODKEY,                     XK_Tab,   view,            {0} },
	{ MODKEY,                     XK_q,     killclient,      {0} },

	/* Layout Switching */
	{ MODKEY,                     XK_t,     setlayout,       {.v = &layouts[0]} },
	{ MODKEY|Mod1Mask,            XK_f,     setlayout,       {.v = &layouts[1]} },
	{ MODKEY,                     XK_m,     setlayout,       {.v = &layouts[2]} },
	{ MODKEY,                     XK_r,     setlayout,       {.v = &layouts[3]} },
	{ MODKEY|ShiftMask,           XK_r,     setlayout,       {.v = &layouts[4]} },
	{ MODKEY,                     XK_y,     setlayout,       {.v = &layouts[14]} },
	{ MODKEY,                     XK_space, setlayout,       {0} },
	{ MODKEY|ShiftMask,           XK_space, togglefloating,  {0} },

	/* Tags */
	{ MODKEY,                     XK_0,     view,            {.ui = ~0 } },
	{ MODKEY|ShiftMask,           XK_0,     tag,             {.ui = ~0 } },
	TAGKEYS(                      XK_1,                      0)
	TAGKEYS(                      XK_2,                      1)
	TAGKEYS(                      XK_3,                      2)
	TAGKEYS(                      XK_4,                      3)
	TAGKEYS(                      XK_5,                      4)
	TAGKEYS(                      XK_6,                      5)
	TAGKEYS(                      XK_7,                      6)
	TAGKEYS(                      XK_8,                      7)
	TAGKEYS(                      XK_9,                      8)

	/* Quit / Misc */
	{ MODKEY|ShiftMask,           XK_q,     quit,            {0} },
	{ MODKEY,                     XK_o,     winview,         {0} },
	{ Mod1Mask,                   XK_Tab,   alttab,          {0} },
	{ Mod1Mask,                   XK_l,     spawn,           SHCMD("slock") },
};

/* mouse buttons */
static const Button buttons[] = {
	/* click            event mask   button   function        argument */
	{ ClkLtSymbol,      0,           Button1, setlayout,      {0} },
	{ ClkLtSymbol,      0,           Button3, setlayout,      {.v = &layouts[2]} },

	{ ClkFollowSymbol,  0,           Button1, togglefollow,   {0} },

	{ ClkWinTitle,      0,           Button2, zoom,           {0} },
	{ ClkStatusText,    0,           Button2, spawn,          {.v = termcmd } },
	{ ClkClientWin,     MODKEY,      Button1, movemouse,      {0} },
	{ ClkClientWin,     MODKEY,      Button2, togglefloating, {0} },
	{ ClkClientWin,     MODKEY,      Button3, resizemouse,    {0} },
	{ ClkTagBar,        0,           Button1, view,           {0} },
	{ ClkTagBar,        0,           Button3, toggleview,     {0} },
	{ ClkTagBar,        MODKEY,      Button1, tag,            {0} },
	{ ClkTagBar,        MODKEY,      Button3, toggletag,      {0} },
};
