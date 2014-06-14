#!/bin/sh

hsetroot -tile ~/.themes/background.png

xrdb -load ~/.Xresources

xrandr --output DVI-I-1 --pos 0x0 --mode 1680x1050
xrandr --output DVI-D-1 --pos 1680x0 --mode 1920x1080
xrandr --output HDMI-1 --pos 3700x0 --mode 1280x1024 

# cmus &
xmms2-launcher

dunst -cconf ~/.config/dunst/dunstrc &

python .linconnect/LinConnectServer/main/linconnect_server.py &

# Launch WM
sxhkd &
exec bspwm
