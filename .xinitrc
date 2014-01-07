#!/bin/sh

hsetroot -tile ~/.themes/background.png

xrdb -load ~/.Xresources

compton -c -b


# cmus &

# Launch WM
sxhkd &
exec bspwm
