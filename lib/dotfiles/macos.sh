# lib/dotfiles/macos.sh — shared helpers for the macOS reset-catalog tasks

# Collect reset-catalog file paths (global + machine sidecar).
macos_settings_files() {
    local files=("$DOTFILES_DIR/macos/settings.sh")
    local machine_file="$DOTFILES_DIR/macos/settings.${DOTFILES_MACHINE}.sh"
    [[ -f "$machine_file" ]] && files+=("$machine_file")
    printf '%s\n' "${files[@]}"
}

# Strip surrounding quotes (and any trailing comment) from a defaults key.
_macos_clean_value() {
    local v="$1"
    v="${v%%#*}"               # strip trailing comment
    v="${v%"${v##*[! ]}"}"     # trim trailing whitespace
    v="${v#\"}" ; v="${v%\"}"  # strip surrounding double quotes
    v="${v#\'}" ; v="${v%\'}"  # strip surrounding single quotes
    printf '%s' "$v"
}

# Parse `defaults delete` reset-catalog lines from a file.
# Appends to the caller's _dw_domains and _dw_keys parallel arrays.
# Scalar `defaults write` preferences live in [bootstrap.macos.defaults], not here.
macos_parse_defaults() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    while IFS= read -r line; do
        if [[ "$line" =~ ^defaults\ delete\ ([^\ ]+)\ (.+)$ ]]; then
            _dw_domains+=("${BASH_REMATCH[1]}")
            _dw_keys+=("$(_macos_clean_value "${BASH_REMATCH[2]}")")
        fi
    done < "$file"
}
