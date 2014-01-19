#!/bin/sh

hsetroot -tile ~/.themes/background.png

xrdb -load ~/.Xresources

# compton -c -b

# cmus &
xmms2-launcher

# Launch WM
sxhkd &
exec bspwm
