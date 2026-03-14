# lib/dotfiles/symlinks.sh — symlink link:target pairs
dotfiles_symlinks=(
    # claude
    "$HOME/.claude/CLAUDE.md:$DOTFILES_DIR/claude/CLAUDE.md"
    "$HOME/.claude/LESSONS.md:$DOTFILES_DIR/claude/LESSONS.md"
    # shell/bash
    "$HOME/.bash_profile:$DOTFILES_DIR/shell/bash/.bash_profile"
    "$HOME/.bashrc:$DOTFILES_DIR/shell/bash/.bashrc"
    # shell/zsh
    "$HOME/.zshenv:$DOTFILES_DIR/shell/zsh/.zshenv"
    # ssh
    "$HOME/.ssh/config:$DOTFILES_DIR/ssh/config"
)
