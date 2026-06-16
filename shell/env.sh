# shellcheck shell=bash
# $DOTFILES_DIR/shell/env.sh
# Shared environment variables — sourced by .zshenv and bash_env.
# Requires bash or zsh (uses [[ ]] syntax).
# Does NOT contain: HISTFILE, ZDOTDIR, interactive config, activations.

# Load user overrides for DOTFILES_DIR, XDG vars, etc. if present.
if [[ -f "$HOME/.dotfiles" ]]; then
	# shellcheck source=/dev/null  # machine-local overrides, not part of the repo
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

# Trust the project-local mise task scope under $DOTFILES_DIR/.config/mise.
# The dotfiles tasks live there, scoped to this tree rather than the global config dir,
# and mise refuses to load a non-global config until it is trusted.
# This lives here, where $DOTFILES_DIR is defined,
# because trusted_config_paths in the global config.toml is parsed too early to expand vars.
# The list is comma-separated; append so any existing value is preserved.
export MISE_TRUSTED_CONFIG_PATHS="${MISE_TRUSTED_CONFIG_PATHS:+$MISE_TRUSTED_CONFIG_PATHS,}$DOTFILES_DIR/.config/mise"

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

# Rustup — toolchain store; mise's rust installs are symlinks to cargo/bin
# (rustup proxies), so they resolve toolchains here at runtime.
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Go — GOPATH, GOMODCACHE, and GOCACHE live in the env file at $GOENV,
# rendered from go/env.tmpl by mise [dotfiles] (see config.toml).
# GOENV must be set here so Go finds that file before reading it.
export GOENV="$XDG_CONFIG_HOME/go/env"

# Bun
export BUN_INSTALL="$XDG_DATA_HOME/bun"

# Docker — the config dir is machine state (current context, context metadata,
# mise-symlinked cli-plugins), not portable config, so it lives in state.
export DOCKER_CONFIG="$XDG_STATE_HOME/docker"

# npm — no native XDG support. Cache is regenerable; userconfig (.npmrc) is real
# config but npm writes auth tokens there, so it's deny-by-default in .gitignore.
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
# Silence npm's update-notifier banner.
# npm is only a mise backend helper here (bun does the installs;
# mise still shells out to `npm view` for version resolution),
# so its self-update nag during `mise run update` is pure noise.
export NO_UPDATE_NOTIFIER=1

# Vim — relocate viminfo to state (helix is $EDITOR; no vimrc in use).
export VIMINIT="set viminfofile=$XDG_STATE_HOME/vim/viminfo"

# --- OS & Machine Layers ------------------

# shellcheck source=/dev/null  # path resolved at runtime from $DOTFILES_OS
[[ -f "$DOTFILES_DIR/shell/env.${DOTFILES_OS}.sh" ]] && source "$DOTFILES_DIR/shell/env.${DOTFILES_OS}.sh"
# shellcheck source=/dev/null  # path resolved at runtime from $DOTFILES_MACHINE
[[ -f "$DOTFILES_DIR/shell/env.${DOTFILES_MACHINE}.sh" ]] && source "$DOTFILES_DIR/shell/env.${DOTFILES_MACHINE}.sh"
