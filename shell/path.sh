# shellcheck shell=bash
# $DOTFILES_DIR/shell/path.sh
# PATH construction — sourced by env.sh (every shell, via .zshenv)
# and again by $ZDOTDIR/.zprofile on login shells AFTER /etc/zprofile runs path_helper.
#
# path_helper (login shells only) re-prepends the system dirs (/usr/bin, /bin, …) to the FRONT of PATH,
# which would otherwise shadow Homebrew and mise with macOS's stock tools
# (e.g. git 2.50 instead of brew's 2.54, breaking git 2.54+ config-based hooks).
# Re-sourcing this file after path_helper restores the intended order.
# `typeset -U PATH path` (set in .zshenv) dedups,
# so the re-prepend just moves these entries back to the front.
# mise activation runs later in .zshrc and still prepends tool dirs ahead of everything.
#
# Requires bash or zsh (uses [[ ]] syntax).
# Assumes XDG_* are already exported.

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

# cmux CLI (macOS app bundle)
if [[ -d "$HOME/Applications/cmux.app" ]]; then
	export PATH="$HOME/Applications/cmux.app/Contents/Resources/bin:$PATH"
elif [[ -d "/Applications/cmux.app" ]]; then
	export PATH="/Applications/cmux.app/Contents/Resources/bin:$PATH"
fi
