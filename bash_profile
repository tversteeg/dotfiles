#!/bin/bash

# Honor per-interactive-shell startup file
if [ -f ~/.bashrc ]; then . /home/thomas/.bashrc; fi

# Add local binaries to path
export PATH=$PATH:~/.local/bin

# Load Rust
source /home/thomas/.cargo/env

# Set SSH agent socket
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Run sway
export MOZ_ENABLE_WAYLAND=1
export XDG_CURRENT_DESKTOP=niri
export XDG_SESSION_TYPE=wayland
#[ "$(tty)" = "/dev/tty1" ] && exec dbus-launch --sh-syntax --exit-with-session sway
[ "$(tty)" = "/dev/tty1" ] && exec dbus-launch --sh-syntax --exit-with-session niri -c /home/thomas/.config/niri/config.kdl
