#!/bin/bash

# Honor per-interactive-shell startup file
if [ -f ~/.bashrc ]; then . /home/thomas/.bashrc; fi

# Add local binaries to path
export PATH=$PATH:~/.local/bin

# Load Rust
source /home/thomas/.cargo/env

# Run sway
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
[ "$(tty)" = "/dev/tty1" ] && exec dbus-launch --sh-syntax --exit-with-session sway
