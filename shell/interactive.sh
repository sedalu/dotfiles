# $DOTFILES_DIR/shell/interactive.sh
# Shared interactive config — sourced by .zshrc and .bashrc.
# Contains: pager, fzf, functions.
# Aliases are managed via [shell_aliases] in the mise global config.

# --- Pager ------------------------------

export PAGER="bat --paging=always"
export GIT_PAGER="delta"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# --- fzf --------------------------------

export FZF_DEFAULT_OPTS=$'
    --height 40%
    --layout=reverse
    --border
    --color=bg+:#313244,fg:#cdd6f4,fg+:#cdd6f4
    --color=hl:#f38ba8,hl+:#f38ba8
    --color=border:#45475a,header:#f38ba8,info:#cba6f7
    --color=marker:#f5e0dc,pointer:#f5e0dc,prompt:#cba6f7
    --color=spinner:#f5e0dc
'

# ripgrep as the default file source
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'

# Ctrl+T — fuzzy file picker with bat preview
export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range :200 {} 2>/dev/null || eza --tree --level=2 --icons=always --color=always {}'"

# Alt+C — fuzzy directory jump via zoxide
export FZF_ALT_C_COMMAND='zoxide query --list'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"

rg-fzf() {
    rg --color=always --line-number --no-heading --smart-case "${*:--}" |
        fzf --ansi \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter ':' \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
            --bind 'enter:become($EDITOR {1}:{2})'
}

# --- Functions --------------------------
# Shell functions that must affect the current shell's state.
# Other utilities (extract, genpass, port, etc.) live in $DOTFILES_DIR/bin.

# Create a directory and cd into it.
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Reload the current shell's rc file.
reload() {
    if [[ -n "$ZSH_VERSION" ]]; then
        source "$HOME/.zshenv"
    elif [[ -n "$BASH_VERSION" ]]; then
        source "$HOME/.bashrc"
    fi
}
