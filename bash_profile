#!/bin/bash

# Run sway
export MOZ_ENABLE_WAYLAND=1
#export XDG_CURRENT_DESKTOP=niri
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
[ "$(tty)" = "/dev/tty1" ] && exec dbus-launch --sh-syntax --exit-with-session sway
#[ "$(tty)" = "/dev/tty1" ] && exec dbus-launch --sh-syntax --exit-with-session niri -c /home/thomas/.config/niri/config.kdl
