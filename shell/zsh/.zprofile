# $ZDOTDIR/.zprofile
#
# Zsh load order:
#   /etc/zshenv           system    always
#   ~/.zshenv             user      always
#   /etc/zprofile         system    login
# > $ZDOTDIR/.zprofile    user      login
#   /etc/zshrc            system    interactive
#   $ZDOTDIR/.zshrc       user      interactive
#   /etc/zlogin           system    login
#   $ZDOTDIR/.zlogin      user      login
#   $ZDOTDIR/.zlogout     user      login, on exit
#   /etc/zlogout          system    login, on exit

# --- PATH precedence (login shells) -----
#
# /etc/zprofile (above) runs path_helper, which re-prepends the system dirs
# (/usr/bin, …) to the FRONT of PATH — shadowing the Homebrew + mise paths that
# .zshenv -> env.sh set, so `git` would resolve to macOS's stock 2.50 instead
# of brew's 2.54 (which breaks git 2.54+ config-based hooks). Re-source path.sh
# here, after path_helper, to restore the intended order. `typeset -U path`
# dedups; mise activation in .zshrc runs later and still wins.
source "${DOTFILES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}}/shell/path.sh"
