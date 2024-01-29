if status is-interactive
    # History access
    atuin init fish | source

    # PS1 prompt
    starship init fish | source

    # Aliases
    alias ls='lsd'
    alias tree='et'
    alias cat='bat --theme=base16-256'
    alias grep='grep --color=auto'
    alias c='cemsdev run'
    alias ga='git add -A'
    alias gc='git commit -am'

    # sudo !!
    function sudo
        if test "$argv" = !!
            eval command sudo $history[1]
        else
            command sudo $argv
        end
    end
end
