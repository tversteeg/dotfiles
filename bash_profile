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
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
[ "$(tty)" = "/dev/tty1" ] && exec dbus-launch --sh-syntax --exit-with-session sway

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
