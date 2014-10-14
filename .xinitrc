#!/bin/sh

hsetroot -tile ~/.themes/background.png

xrdb ~/.Xresources

# Launch WM
sxhkd &
exec bspwm
