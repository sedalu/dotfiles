# ~/.bash_logout -> $DOTFILES_DIR/shell/bash/.bash_logout
#
# Bash login shell load order:
#   /etc/profile          system
#   ~/.bash_profile       user      first found
#   ~/.bash_login         user      first found (skipped — .bash_profile exists)
#   ~/.profile            user      first found (skipped — .bash_profile exists)
# > ~/.bash_logout        user      on exit
