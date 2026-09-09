#!/usr/bin/env python3
import subprocess
import time

MAX_LENGTH = 28
INTERVAL = 0.15


def command(*args):
    try:
        return subprocess.run(
            args, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
            text=True, check=False
        ).stdout.strip()
    except OSError:
        return ""


def active_title():
    window = command("xdotool", "getactivewindow")
    if not window:
        return ""
    title = command("xdotool", "getwindowname", window)
    return title.replace("\n", " ").strip()


def frames(text):
    if len(text) <= MAX_LENGTH:
        return [text]
    padded = text + "   "
    doubled = padded + padded
    return [doubled[i:i + MAX_LENGTH] for i in range(len(padded))]


last = None
sequence = [""]
index = 0
while True:
    title = active_title()
    if title != last:
        sequence = frames(title)
        index = 0
        last = title
    if sequence:
        print(sequence[index], flush=True)
        index = (index + 1) % len(sequence)
    time.sleep(INTERVAL)
