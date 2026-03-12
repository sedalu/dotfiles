# ~/.bashrc -> $DOTFILES_DIR/shell/bash/.bashrc
#
# Bash interactive non-login load order:
#   /etc/bash.bashrc      system    Linux only
# > ~/.bashrc             user
#
# Bash login shell load order:
#   /etc/profile          system
#   ~/.bash_profile       user      (sources this file explicitly)
#
# Bash non-interactive load order:
#   $BASH_ENV             env       if set

# Exit if not interactive.
[[ $- != *i* ]] && return

# Ensure environment is loaded. In login shells, .bash_profile already sourced
# bash_env. In non-login shells spawned from zsh, env vars are inherited. This
# covers the edge case of a non-login bash shell in a clean environment
# (containers, `env -i bash`, etc.).
if [[ -z "$HOMEBREW_PREFIX" ]]; then
    if [[ -f "$HOME/.dotfiles" ]]; then
        source "$HOME/.dotfiles"
    fi
    source "${DOTFILES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}}/shell/bash/bash_env"
fi

# --- Activations ------------------------

if command -v mise &>/dev/null; then
    eval "$(mise activate bash)"
fi

# Generic caching function — regenerates init script if binary is newer than cache.
_cached_source() {
    local name="$1"
    shift
    local cmd="$1"
    local cache="$XDG_CACHE_HOME/bash/init/${name}.bash"
    local bin_path
    bin_path="$(command -v "$cmd" 2>/dev/null)"

    if [[ ! -s "$cache" || "$bin_path" -nt "$cache" ]]; then
        mkdir -p "${cache%/*}"
        "$@" > "$cache" 2>/dev/null
    fi

    source "$cache"
}

command -v fnox    &>/dev/null && _cached_source fnox fnox activate bash
command -v fzf     &>/dev/null && _cached_source fzf fzf --bash
command -v starship &>/dev/null && _cached_source starship starship init bash
command -v zoxide  &>/dev/null && _cached_source zoxide zoxide init bash

# --- History ----------------------------

HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoredups:erasedups:ignorespace
HISTIGNORE='ls:ll:la:cd:pwd:exit:clear'

shopt -s histappend

# Share history across sessions (equivalent to zsh SHARE_HISTORY).
PROMPT_COMMAND="history -a; history -c; history -r${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# --- Completions ------------------------

if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
fi

# --- General ----------------------------

shopt -s nocaseglob   # case-insensitive globbing
shopt -s cdspell      # minor typo correction for cd
shopt -s dirspell     # directory spell correction on completion
shopt -s autocd       # cd by typing a directory name
shopt -s checkwinsize # update LINES/COLUMNS after each command

# Emacs key bindings (default).
set -o emacs
# Up/Down arrows — history substring search.
bind '"\\e[A": history-search-backward'
bind '"\\e[B": history-search-forward'
# Ctrl+X Ctrl+E — edit command line in $EDITOR.
bind '"\\C-x\\C-e": edit-and-execute-command'

# --- Shared interactive config ----------

source "$DOTFILES_DIR/shell/interactive.sh"
