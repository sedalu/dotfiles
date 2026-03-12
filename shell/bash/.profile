# ~/.profile -> $DOTFILES_DIR/shell/bash/.profile
#
# Bash login shell load order:
#   /etc/profile          system
#   ~/.bash_profile       user      first found (skipped — .profile only read if .bash_profile and .bash_login absent)
#   ~/.bash_login         user      first found (skipped — .profile only read if .bash_profile and .bash_login absent)
# > ~/.profile            user      first found
#   ~/.bash_logout        user      on exit
#
# Bash interactive non-login load order:
#   /etc/bash.bashrc      system    Linux only
#   ~/.bashrc             user
#
# Bash non-interactive load order:
#   $BASH_ENV             env       if set
#
# Note: also read by dash, ash, and other POSIX sh login shells.
