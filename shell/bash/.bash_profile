# ~/.bash_profile -> $DOTFILES_DIR/shell/bash/.bash_profile
#
# Bash login shell load order:
#   /etc/profile          system
# > ~/.bash_profile       user      first found
#   ~/.bash_login         user      first found (skipped — .bash_profile exists)
#   ~/.profile            user      first found (skipped — .bash_profile exists)
#   ~/.bash_logout        user      on exit
#
# Bash interactive non-login load order:
#   /etc/bash.bashrc      system    Linux only
#   ~/.bashrc             user
#
# Bash non-interactive load order:
#   $BASH_ENV             env       if set
#
# Note: this file explicitly sources .bashrc so interactive login shells
#       (e.g. macOS Terminal.app, which opens login shells) get interactive config.

if [[ -f "$HOME/.dotfiles" ]]; then
    source "$HOME/.dotfiles"
fi
source "${DOTFILES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}}/shell/bash/bash_env"

# Ensure state dirs exist.
[[ -d "$XDG_STATE_HOME/bash" ]] || mkdir -p "$XDG_STATE_HOME/bash"
[[ -d "$XDG_CACHE_HOME/bash" ]] || mkdir -p "$XDG_CACHE_HOME/bash"

# Export BASH_ENV so non-interactive scripts inherit the environment.
export BASH_ENV="$DOTFILES_DIR/shell/bash/bash_env"

# Source .bashrc for interactive login shells.
if [[ -f "$DOTFILES_DIR/shell/bash/.bashrc" ]]; then
    source "$DOTFILES_DIR/shell/bash/.bashrc"
fi
