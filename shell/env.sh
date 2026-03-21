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

export PATH="${XDG_CONFIG_HOME}/bin:${PATH}"
export PATH="${HOME}/.local/bin:${PATH}"

# Homebrew
if [[ -d /opt/homebrew ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:${PATH}"
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
    export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
fi

# mise shims
export PATH="$XDG_DATA_HOME/mise/shims:$PATH"

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
export HOMEBREW_BUNDLE_FILE="$DOTFILES_DIR/brew/Brewfile"

# --- Editor -----------------------------

export EDITOR="$XDG_DATA_HOME/mise/shims/hx"
export VISUAL="$EDITOR"

# --- Less -------------------------------

export LESS='-R --quit-if-one-screen --no-init --ignore-case --LONG-PROMPT --RAW-CONTROL-CHARS'
export LESSHISTFILE="$XDG_STATE_HOME/less_history"

# --- Tools ------------------------------

# Cargo
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# Go — GOPATH, GOMODCACHE, and GOCACHE are managed via `go env -w`
# through mise tasks (see dotfiles:install:go). GOENV must be set
# here so Go knows where to find its env file before reading it.
export GOENV="$XDG_CONFIG_HOME/go/env"

# Bun
export BUN_INSTALL="$XDG_DATA_HOME/bun"

# --- OS & Machine Layers ------------------

[[ -f "$DOTFILES_DIR/shell/env.${DOTFILES_OS}.sh" ]] && source "$DOTFILES_DIR/shell/env.${DOTFILES_OS}.sh"
[[ -f "$DOTFILES_DIR/shell/env.${DOTFILES_MACHINE}.sh" ]] && source "$DOTFILES_DIR/shell/env.${DOTFILES_MACHINE}.sh"
