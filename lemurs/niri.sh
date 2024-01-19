#!/bin/sh

# Set the current desktop for xdg-desktop-portal
export XDG_CURRENT_DESKTOP=niri
export XDG_SESSION_DESKTOP=niri

# Ensure the session type is set to Wayland for xdg-autostart apps
export XDG_SESSION_TYPE=wayland

# Use wayland for floorp
export MOZ_ENABLE_WAYLAND=1

# Expose the local user SSH agent which is run as a systemd service, can be enabled on new configs with `servicectl --user enable --now ssh-agent`
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"

# Run player control daemon for media
echo "playerctld daemon" | at now

# Run KDEconnect daemon
echo "/usr/lib/x86_64-linux-gnu/libexec/kdeconnectd" | at now

# Activate xdg-desktop portal
systemctl --user import-environment
dbus-update-activation-environment --all
dbus-update-activation-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE

# Start the desktop environment
exec systemctl --user --wait start niri.service
