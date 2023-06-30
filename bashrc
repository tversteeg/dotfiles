#!/bin/bash

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# Make the history very big
HISTSIZE=100000
HISTFILESIZE=200000

# Export 'SHELL' to child processes
export SHELL

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# The pattern "**" used in a pathname expansion context will match all files and zero or more directories and subdirectories
shopt -s globstar

if [[ $- != *i* ]]; then
	# We are being invoked from a non-interactive shell.  If this
	# is an SSH session (as in "ssh host command"), source
	# /etc/profile so we get PATH and other essential variables
	[[ -n "$SSH_CLIENT" ]] && source /etc/profile

	# Don't do anything else
	return
fi

# Set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# Enable programmable completion features
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

# Cache Rust build artifacts
#export RUSTC_WRAPPER=sccache

# Setup rust
source "$HOME/.cargo/env"

# Setup FZF
source /usr/share/doc/fzf/examples/key-bindings.bash
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Use better alternatives
alias ls='lsd'
alias tree='et'
alias cat='bat --theme=base16-256'
alias grep='grep --color=auto'
alias c='cemsdev run'
alias ga='git add -A'
alias gc='git commit -am'

# Add installed cargo binaries to path, and ~/.local/bin, and the lua language server, and neovim
export PATH="$PATH:/home/thomas/.cargo/bin:/home/thomas/.local/bin:/home/thomas/r/lua-language-server/bin:/home/thomas/.local/share/neovim/bin:/home/thomas/.yarn/bin"

# Expose 'z'
eval "$(zoxide init bash)"

# Use a nice prompt
eval "$(starship init bash)"

# Add completions for glab if installed
type "glab" >/dev/null 2>&1 && eval "$(glab completion)"

# Use neovim as the default editor
export EDITOR='hx'

# Use ripgrep as the FZF input
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Show a nice preview for FZF
export FZF_DEFAULT_OPTS='--preview-window=:hidden --preview "bat {}"'

# Directories for zellij files
export ZELLIJ_LAYOUT_DIR=~/.dotfiles/zellij/.config/zellij/layouts

# Start a new zellij session when opening a new shell
if [[ -z "$ZELLIJ" ]] && [ "$(tty)" != "/dev/tty1" ]; then
	 ~/.local/bin/start-zellij-session
	exit
fi

# Use gcloud for kubectl
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Start flavours
# Base16 Summerfruit Light
# Author: Christopher Corley (http://christop.club/)

_gen_fzf_default_opts() {

local color00='#FFFFFF'
local color01='#E0E0E0'
local color02='#D0D0D0'
local color03='#B0B0B0'
local color04='#000000'
local color05='#101010'
local color06='#151515'
local color07='#202020'
local color08='#FF0086'
local color09='#FD8900'
local color0A='#ABA800'
local color0B='#00C918'
local color0C='#1FAAAA'
local color0D='#3777E6'
local color0E='#AD00A1'
local color0F='#CC6633'

export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"\
" --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D"\
" --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C"\
" --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D"

}

_gen_fzf_default_opts
# End flavours
