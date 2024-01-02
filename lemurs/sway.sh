#!/bin/sh

# Set SSH agent socket
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

export MOZ_ENABLE_WAYLAND=1

exec sway
