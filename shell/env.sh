# $DOTFILES_DIR/shell/env.sh
# Shared environment variables — sourced by .zshenv and bash_env.
# Requires bash or zsh (uses [[ ]] syntax).
# Does NOT contain: HISTFILE, ZDOTDIR, interactive config, activations.

# Load user overrides for DOTFILES_DIR, XDG vars, etc. if present.
if [[ -f "$HOME/.dotfiles" ]]; then
    source "$HOME/.dotfiles"
fi

# --- XDG Base Directories ---------------

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# --- XDG User Directories ---------------

if [[ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ]]; then
    source "$XDG_CONFIG_HOME/user-dirs.dirs"
    export XDG_DESKTOP_DIR
    export XDG_DOWNLOAD_DIR
    export XDG_TEMPLATES_DIR
    export XDG_PUBLICSHARE_DIR
    export XDG_DOCUMENTS_DIR
    export XDG_MUSIC_DIR
    export XDG_PICTURES_DIR
    export XDG_VIDEOS_DIR
    export XDG_PROJECTS_DIR
fi

# --- Homebrew ---------------------------
# Hardcoded to avoid a subprocess from `brew shellenv` on every shell start.

if [[ -d /opt/homebrew ]]; then
    # macOS (Apple Silicon)
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
    # Linux
    export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
    export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
    export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
    export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:${INFOPATH:-}"
fi

# --- PATH -------------------------------
# Factored into path.sh so login shells can re-apply it after path_helper
# (see path.sh header). XDG_CONFIG_HOME is set above; DOTFILES_DIR is not yet,
# so resolve the same way .zshenv resolves env.sh.

source "${DOTFILES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}}/shell/path.sh"

# --- Dotfiles ---------------------------

export DOTFILES_DIR="${DOTFILES_DIR:-$XDG_CONFIG_HOME}"
export DOTFILES_GIT="${DOTFILES_GIT:-$XDG_DATA_HOME/dotfiles.git}"

if [[ "$(uname -s)" == "Darwin" ]]; then
    _dotfiles_raw_host="$(scutil --get LocalHostName 2>/dev/null || hostname)"
else
    _dotfiles_raw_host="$(hostname)"
fi
export DOTFILES_MACHINE="${DOTFILES_MACHINE:-$(printf '%s' "$_dotfiles_raw_host" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/--*/-/g;s/^-//;s/-$//')}"
unset _dotfiles_raw_host
export DOTFILES_OS="${DOTFILES_OS:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
export DOTFILES_SHELL="${DOTFILES_SHELL:-$(basename "$SHELL")}"

# Homebrew Bundle
export HOMEBREW_BUNDLE_FILE="$DOTFILES_DIR/homebrew/Brewfile"

# --- Editor -----------------------------

export EDITOR="$XDG_DATA_HOME/mise/shims/hx"
export VISUAL="$EDITOR"

# --- Less -------------------------------

export LESS='-R --quit-if-one-screen --no-init --ignore-case --LONG-PROMPT --RAW-CONTROL-CHARS'
export LESSHISTFILE="$XDG_STATE_HOME/less_history"

# --- Tools ------------------------------

# Cargo
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# Go — GOPATH, GOMODCACHE, and GOCACHE live in the env file at $GOENV,
# rendered from go/env.tmpl by mise [dotfiles] (see config.toml).
# GOENV must be set here so Go finds that file before reading it.
export GOENV="$XDG_CONFIG_HOME/go/env"

# Bun
export BUN_INSTALL="$XDG_DATA_HOME/bun"

# --- OS & Machine Layers ------------------

[[ -f "$DOTFILES_DIR/shell/env.${DOTFILES_OS}.sh" ]] && source "$DOTFILES_DIR/shell/env.${DOTFILES_OS}.sh"
[[ -f "$DOTFILES_DIR/shell/env.${DOTFILES_MACHINE}.sh" ]] && source "$DOTFILES_DIR/shell/env.${DOTFILES_MACHINE}.sh"
