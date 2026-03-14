# lib/dotfiles/dirs.sh — XDG directories to create and verify
dotfiles_dirs=(
    # xdg
    "$XDG_CACHE_HOME"
    "$XDG_CONFIG_HOME"
    "$XDG_DATA_HOME"
    "$XDG_STATE_HOME"
    # shell/bash
    "$XDG_DATA_HOME/bash/completions"
    "$XDG_STATE_HOME/bash"
    # shell/zsh
    "$XDG_STATE_HOME/zsh"
    "$XDG_CACHE_HOME/zsh/init"
    "$XDG_DATA_HOME/zsh/site-functions"
)
