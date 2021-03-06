# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
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

if [[ $- != *i* ]]
then
	# We are being invoked from a non-interactive shell.  If this
	# is an SSH session (as in "ssh host command"), source
	# /etc/profile so we get PATH and other essential variables
	[[ -n "$SSH_CLIENT" ]] && source /etc/profile

	# Don't do anything else
	return
fi

# Only apply the guix specific settings
if [ -n "$GUIX_LOCPATH" ]
then
	# Source the system-wide file.
	source /etc/bashrc

	# Adjust the prompt depending on whether we're in 'guix environment'
	if [ -n "$GUIX_ENVIRONMENT" ]
	then
		PS1='\u@\h \w [env]\$ '
	else
		PS1='\u@\h \w\$ '
	fi

	# Use our own channel with guix
	export GUIX_PACKAGE_PATH="~/.guix-channel/local"
	# Add extra local profiles
	export GUIX_EXTRA_PROFILES="~/.guix-extra-profiles"
else
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
	export RUSTC_WRAPPER=sccache

	# Setup rust
	source $HOME/.cargo/env

	# Setup FZF
	source /usr/share/doc/fzf/examples/key-bindings.bash
	[ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

# Use better alternatives
alias ls='lsd'
alias cat='bat'
alias grep='grep --color=auto'

# Add installed cargo binaries to path
export PATH="$PATH:~/.cargo/bin"

# Expose 'z'
eval "$(zoxide init bash)"

# Use Ctrl-G for navi
eval "$(navi widget bash)"

# Use a nice prompt
eval "$(starship init bash)"

# Use neovim as the default editor
export EDITOR='nvim'

# Use ripgrep as the FZF input
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Show a nice preview for FZF
export FZF_DEFAULT_OPTS='--preview-window=:hidden --preview "bat {}"'

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
