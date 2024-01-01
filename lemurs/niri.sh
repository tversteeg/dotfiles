#!/bin/sh

export MOZ_ENABLE_WAYLAND=1
export XDG_CURRENT_DESKTOP=niri
export XDG_SESSION_TYPE=wayland

# Import login manager env
systemctl --user import-environment

# Update env vars for D-Bus
if hash dbus-update-activation-environment 2>/dev/null; then
    dbus-update-activation-environment --all
fi

exec dbus-launch --sh-syntax --exit-with-session niri
