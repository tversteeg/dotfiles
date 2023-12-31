#!/bin/sh

export MOZ_ENABLE_WAYLAND=1
export XDG_CURRENT_DESKTOP=niri
export XDG_SESSION_TYPE=wayland

exec dbus-launch --sh-syntax --exit-with-session niri
