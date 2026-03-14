# lib/dotfiles/symlinks.sh — symlink link:target pairs
dotfiles_symlinks=(
    # claude
    "$HOME/.claude:$DOTFILES_DIR/claude"
    # shell/bash
    "$HOME/.bash_profile:$DOTFILES_DIR/shell/bash/.bash_profile"
    "$HOME/.bashrc:$DOTFILES_DIR/shell/bash/.bashrc"
    # shell/zsh
    "$HOME/.zshenv:$DOTFILES_DIR/shell/zsh/.zshenv"
    # ssh
    "$HOME/.ssh/config:$DOTFILES_DIR/ssh/config"
)

# Machine-specific symlinks (e.g., symlinks.caladan.sh)
_machine_symlinks="$DOTFILES_DIR/lib/dotfiles/symlinks.${DOTFILES_MACHINE}.sh"
if [[ -f "$_machine_symlinks" ]]; then
    # shellcheck source=/dev/null
    . "$_machine_symlinks"
    dotfiles_symlinks+=("${dotfiles_machine_symlinks[@]}")
fi
unset _machine_symlinks
