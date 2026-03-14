# $ZDOTDIR/.zshrc
#
# Zsh load order:
#   /etc/zshenv           system    always
#   ~/.zshenv             user      always
#   /etc/zprofile         system    login
#   $ZDOTDIR/.zprofile    user      login
#   /etc/zshrc            system    interactive
# > $ZDOTDIR/.zshrc       user      interactive
#   /etc/zlogin           system    login
#   $ZDOTDIR/.zlogin      user      login
#   $ZDOTDIR/.zlogout     user      login, on exit
#   /etc/zlogout          system    login, on exit

# --- Activations ------------------------

if command -v mise &>/dev/null; then
    source <(mise activate zsh)
fi

# Generic caching function — regenerates init script if binary is newer than cache.
_cached_source() {
    local name="$1"
    shift
    local cmd="$1"
    local cache="$XDG_CACHE_HOME/zsh/init/${name}.zsh"
    local bin_path="${commands[$cmd]}"

    if [[ ! -s "$cache" || "$bin_path" -nt "$cache" ]]; then
        mkdir -p "${cache:h}"
        "$@" > "$cache" 2>/dev/null
    fi

    source "$cache"
}

# Safe to cache (static init scripts):
(( $+commands[fnox] ))     && source <(fnox activate zsh 2>/dev/null)
(( $+commands[fzf] ))      && _cached_source fzf fzf --zsh
(( $+commands[starship] )) && _cached_source starship starship init zsh

# --- History ----------------------------

HISTFILE="$XDG_STATE_HOME/zsh/history"  # override /etc/zshrc default
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
# setopt INC_APPEND_HISTORY  # conflicts with SHARE_HISTORY

# --- Completions & Plugins --------------

ZSH_PLUGINS_DIR="${XDG_DATA_HOME}/zsh/plugins"

fpath=(
    $XDG_DATA_HOME/zsh/site-functions
    $ZSH_PLUGINS_DIR/zsh-completions/src
    ${HOMEBREW_PREFIX}/share/zsh/site-functions
    $fpath
)
autoload -Uz compinit
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/compdump"
if [[ -n ${ZSH_COMPDUMP}(#qN.mh+24) ]]; then
    compinit -d "$ZSH_COMPDUMP"
else
    compinit -C -d "$ZSH_COMPDUMP"
fi

# fzf-tab — must load immediately after compinit, before any other plugins.
[[ -f "$ZSH_PLUGINS_DIR/fzf-tab/fzf-tab.plugin.zsh" ]] &&
    source "$ZSH_PLUGINS_DIR/fzf-tab/fzf-tab.plugin.zsh"

# Other plugins — must come after fzf-tab.
[[ -f "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
    source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$ZSH_PLUGINS_DIR/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]] &&
    source "$ZSH_PLUGINS_DIR/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
[[ -f "$ZSH_PLUGINS_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] &&
    source "$ZSH_PLUGINS_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh"

# zoxide — must be after compinit.
(( $+commands[zoxide] )) && _cached_source zoxide zoxide init zsh

setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt AUTO_MENU
setopt AUTO_LIST
setopt AUTO_PARAM_SLASH

zstyle ':completion:*' matcher-list 'm:{a-z}={a-z}'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/completion_cache"

# fzf-tab — preview configuration.
zstyle ':fzf-tab:completion:cd:*' fzf-preview 'eza --tree --level=2 --icons --color=always "$realpath"'
zstyle ':fzf-tab:completion:*:*' fzf-preview 'bat --color=always --style=numbers --line-range :200 "$realpath" 2>/dev/null || eza --tree --level=2 --icons --color=always "$realpath" 2>/dev/null'

# fzf-tab — Catppuccin Mocha colors.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' group-colors \
    $'\033[38;2;203;166;247m' $'\033[38;2;137;180;250m' $'\033[38;2;116;199;236m' \
    $'\033[38;2;148;226;213m' $'\033[38;2;166;227;161m' $'\033[38;2;249;226;175m' \
    $'\033[38;2;250;179;135m' $'\033[38;2;243;138;168m' $'\033[38;2;245;194;231m' \
    $'\033[38;2;180;190;254m' $'\033[38;2;137;220;235m' $'\033[38;2;242;205;205m'
zstyle ':fzf-tab:*' default-color $'\033[38;2;205;214;244m'

# --- General ----------------------------

# setopt CORRECT_ALL
setopt NO_CASE_GLOB
setopt MARK_DIRS
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# --- Key Bindings -----------------------

bindkey -e  # Emacs key bindings

# Up/Down arrows — history substring search.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Alt+Right / Alt+Left — word navigation.
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word

# Alt+Backspace — delete whole word.
bindkey '^[^?' backward-kill-word

# Ctrl+A / Ctrl+E — jump to start/end of line.
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# Ctrl+X Ctrl+E — edit command line in $EDITOR.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# --- Shared interactive config ----------

source "$DOTFILES_DIR/shell/interactive.sh"
