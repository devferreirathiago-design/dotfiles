#!/bin/bash
IMG=$(find /home/ferreira/Pictures/Wallpapers -type f | shuf -n 1)

/usr/bin/swww img "$IMG" --transition-type none
