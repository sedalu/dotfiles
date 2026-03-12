# $ZDOTDIR/.zshenv (~/.zshenv -> $DOTFILES_DIR/shell/zsh/.zshenv)
#
# Zsh load order:
#   /etc/zshenv           system    always
# > ~/.zshenv             user      always
#   /etc/zprofile         system    login
#   $ZDOTDIR/.zprofile    user      login
#   /etc/zshrc            system    interactive
#   $ZDOTDIR/.zshrc       user      interactive
#   /etc/zlogin           system    login
#   $ZDOTDIR/.zlogin      user      login
#   $ZDOTDIR/.zlogout     user      login, on exit
#   /etc/zlogout          system    login, on exit

if [[ -f "$HOME/.dotfiles" ]]; then
    source "$HOME/.dotfiles"
fi
source "${DOTFILES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}}/shell/env.sh"

# --- Zsh-specific -----------------------

export ZDOTDIR="$DOTFILES_DIR/shell/zsh"
typeset -U PATH path fpath
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
