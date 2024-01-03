#!/bin/sh

# Use wayland for floorp
export MOZ_ENABLE_WAYLAND=1

# Expose the local user SSH agent which is run as a systemd service, can be enabled on new configs with `servicectl --user enable --now ssh-agent`
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"

# Run kconnect daemon
/usr/lib/x86_64-linux-gnu/libexec/kdeconnectd &

exec niri
