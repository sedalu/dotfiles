# lib/dotfiles/zsh-plugins.sh — zsh plugin name:url pairs
ZSH_PLUGINS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"

dotfiles_zsh_plugins=(
    "fzf-tab:https://github.com/Aloxaf/fzf-tab.git"
    "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions.git"
    "zsh-completions:https://github.com/zsh-users/zsh-completions.git"
    "zsh-fast-syntax-highlighting:https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
    "zsh-history-substring-search:https://github.com/zsh-users/zsh-history-substring-search.git"
)
