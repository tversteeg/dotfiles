# Bash initialization for interactive non-login shells and
# for remote shells (info "(bash) Bash Startup Files").

# Export 'SHELL' to child processes.  Programs such as 'screen'
# honor it and otherwise use /bin/sh.
export SHELL

if [[ $- != *i* ]]
then
    # We are being invoked from a non-interactive shell.  If this
    # is an SSH session (as in "ssh host command"), source
    # /etc/profile so we get PATH and other essential variables.
    [[ -n "$SSH_CLIENT" ]] && source /etc/profile

    # Don't do anything else.
    return
fi

# Source the system-wide file.
source /etc/bashrc

# Adjust the prompt depending on whether we're in 'guix environment'.
if [ -n "$GUIX_ENVIRONMENT" ]
then
    PS1='\u@\h \w [env]\$ '
else
    PS1='\u@\h \w\$ '
fi
#alias ls='lsd'
alias cat='bat'
alias grep='grep --color=auto'

# Add installed cargo binaries to path
export PATH="$PATH:~/.cargo/bin"

# Inject functionality into bash
eval "$(zoxide init bash)"

# Use neovim as the default editor
export EDITOR='nvim'

# Use our own channel with guix
export GUIX_PACKAGE_PATH="~/.guix-channel/local"
# Add extra local profiles
export GUIX_EXTRA_PROFILES="~/.guix-extra-profiles"

# Use ripgrep as the FZF input
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'
# Show a nice preview for FZF
export FZF_DEFAULT_OPTS='--preview "bat {}"'
