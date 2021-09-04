# Honor per-interactive-shell startup file
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

# Add local binaries to path
export PATH=$PATH:~/.local/bin

# Load Rust
source ~/.cargo/env
