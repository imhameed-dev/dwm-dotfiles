/* dwmblocks: reads the blocks[] array in config.h, runs each block's shell
 * command, joins the output, and writes it to the root window's name — dwm's
 * own updatestatus() already displays whatever text is there, so no changes
 * to dwm itself are needed. A block with interval=0 never runs on a timer;
 * it only updates when sent `kill -RTMIN+<signal> $(pgrep dwmblocks)`
 * (see dwm/config.h's volume keybinds for an example). This file is the
 * upstream dwmblocks program with small safety fixes (blocks time out after 5 seconds, signals only set flags, one X connection, bounded buffers); all customization lives in
 * config.h. The comment at the top of config.h explains how to add, edit or
 * remove a block. */
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<unistd.h>
#include<signal.h>
#include<time.h>
#include<X11/Xlib.h>
#define LENGTH(X) (sizeof(X) / sizeof (X[0]))
#define CMDLENGTH 64
#define TIMEOUT "5"  /* seconds a block command may run before it is killed */

typedef struct {
	char* icon;
	char* command;
	unsigned int interval;
	unsigned int signal;
} Block;
void sighandler(int num);
void getcmds(int time);
#ifndef __OpenBSD__
void getsigcmds(void);
void setupsignals();
void sighandler(int signum);
#endif
int getstatus(char *str, char *last);
void setroot();
void statusloop();
void termhandler(int signum);
#include "config.h"
static Display *dpy;
static int screen;
static Window root;
static char statusbar[LENGTH(blocks)][CMDLENGTH] = {0};
static char statusstr[2][LENGTH(blocks) * CMDLENGTH + 1];
static volatile sig_atomic_t statusContinue = 1;
static volatile sig_atomic_t pending[LENGTH(blocks)];  /* set by signal handler, used by main loop */
static void (*writestatus) () = setroot;

//opens process *cmd and stores output in *output
void getcmd(const Block *block, char *output)
{
	char c[CMDLENGTH] = "";
	int i = strlen(block->icon);
	/* the command runs under "timeout", which also stops its children; a hung
	 * command can no longer freeze the bar. The text goes in an environment
	 * variable so it needs no quoting. */
	if (i > CMDLENGTH - 8 || setenv("BLOCK_CMD", block->command, 1) != 0) {
		output[0] = '\0';
		return;
	}
	FILE *cmdf = popen("timeout -k 1 " TIMEOUT " sh -c \"$BLOCK_CMD\"", "r");
	if (!cmdf) {
		output[0] = '\0';
		return;
	}
	if(fgets(c, CMDLENGTH-i-4, cmdf) == NULL){
		pclose(cmdf);
		output[0] = '\0';
		return;
	}
	char *pos;
	while((pos=strchr(c, '\n')) != NULL)
		*pos = '\0';
	if (strlen(c) == 0){
		pclose(cmdf);
		output[0] = '\0';
		return;
	}
	strcpy(output, block->icon);
	strcpy(output+i, c);
	i += strlen(c);
	if (delim != '\0' && i) {
		output[i++] = ' ';
		output[i++] = delim;
		output[i++] = ' ';
	}
	output[i++] = '\0';
	pclose(cmdf);
}

void getcmds(int time)
{
	const Block* current;
	for(int i = 0; i < LENGTH(blocks); i++)
	{
		current = blocks + i;
		if ((current->interval != 0 && time % current->interval == 0) || time == -1)
			getcmd(current,statusbar[i]);
	}
}

#ifndef __OpenBSD__
void getsigcmds(void)
{
	for (int i = 0; i < LENGTH(blocks); i++)
	{
		if (pending[i]) {
			pending[i] = 0;
			getcmd(blocks + i, statusbar[i]);
		}
	}
}

void setupsignals()
{
	for(int i = 0; i < LENGTH(blocks); i++)
	{
		if (blocks[i].signal > 0)
			signal(SIGRTMIN+blocks[i].signal, sighandler);  /* repeated signals are fine */
	}
}
#endif

int getstatus(char *str, char *last)
{
	strcpy(last, str);
	str[0] = '\0';
	for(int i = 0; i < LENGTH(blocks); i++)
		strcat(str, statusbar[i]);
	if (str[0])
		str[strlen(str)-1] = '\0';
	return strcmp(str, last);//0 if they are the same
}

void setroot()
{
	if (!getstatus(statusstr[0], statusstr[1]))//Only set root if text has changed.
		return;
	if (!dpy) {  /* one X connection, opened once and kept */
		dpy = XOpenDisplay(NULL);
		if (!dpy) {
			statusstr[0][0] = '\0';  /* try again at the next change */
			return;
		}
		screen = DefaultScreen(dpy);
		root = RootWindow(dpy, screen);
	}
	XStoreName(dpy, root, statusstr[0]);
	XFlush(dpy);
}

void statusloop()
{
	#ifndef __OpenBSD__
	setupsignals();
	#endif
	int i = 0;
	time_t last = time(NULL), now;
	getcmds(-1);
	writestatus();
	while(statusContinue)
	{
		sleep(1);  /* a signal ends the sleep early */
		now = time(NULL);
		if (now != last) {
			last = now;
			i++;
			getcmds(i);
		}
		getsigcmds();
		writestatus();
	}
}

#ifndef __OpenBSD__
void sighandler(int signum)
{
	/* only sets flags: running programs inside a signal handler is unsafe */
	for (int i = 0; i < LENGTH(blocks); i++)
		if (blocks[i].signal == signum - SIGRTMIN)
			pending[i] = 1;
}
#endif

void termhandler(int signum)
{
	statusContinue = 0;  /* the main loop sees this and ends */
}

int main(int argc, char** argv)
{
	for(int i = 0; i < argc; i++)
	{
		if (!strcmp("-d",argv[i]))
			delim = argv[++i][0];
	}
	signal(SIGTERM, termhandler);
	signal(SIGINT, termhandler);
	statusloop();
	if (dpy)
		XCloseDisplay(dpy);
	return 0;
}
