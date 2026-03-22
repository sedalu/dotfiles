# lib/dotfiles/macos.sh — shared helpers for macOS defaults tasks

# Collect settings file paths (global + machine sidecar)
macos_settings_files() {
    local files=("$DOTFILES_DIR/macos/settings.sh")
    local machine_file="$DOTFILES_DIR/macos/settings.${DOTFILES_MACHINE}.sh"
    [[ -f "$machine_file" ]] && files+=("$machine_file")
    printf '%s\n' "${files[@]}"
}

# Strip trailing # comments and surrounding quotes from a value.
_macos_clean_value() {
    local v="$1"
    v="${v%%#*}"        # strip trailing comment
    v="${v%"${v##*[! ]}"}"  # trim trailing whitespace
    v="${v#\"}" ; v="${v%\"}"  # strip surrounding double quotes
    v="${v#\'}" ; v="${v%\'}"  # strip surrounding single quotes
    printf '%s' "$v"
}

# Parse defaults write/delete lines from a file into parallel arrays.
# Appends to caller's: _dw_domains, _dw_keys, _dw_types, _dw_values
# Delete lines use type=__delete__ and value=__delete__.
macos_parse_defaults() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    while IFS= read -r line; do
        if [[ "$line" =~ ^defaults\ write\ ([^\ ]+)\ ([^\ ]+)\ -([^\ ]+)\ (.+)$ ]]; then
            _dw_domains+=("${BASH_REMATCH[1]}")
            _dw_keys+=("$(_macos_clean_value "${BASH_REMATCH[2]}")")
            _dw_types+=("${BASH_REMATCH[3]}")
            _dw_values+=("$(_macos_clean_value "${BASH_REMATCH[4]}")")
        elif [[ "$line" =~ ^defaults\ delete\ ([^\ ]+)\ (.+)$ ]]; then
            _dw_domains+=("${BASH_REMATCH[1]}")
            _dw_keys+=("$(_macos_clean_value "${BASH_REMATCH[2]}")")
            _dw_types+=("__delete__")
            _dw_values+=("__delete__")
        fi
    done < "$file"
}

# Compare an expected value against current defaults read output.
# Returns 0 if they match, 1 if they differ.
macos_values_match() {
    local type="$1" expected="$2" current="$3"
    if [[ "$type" == "bool" ]]; then
        [[ "$expected" == "true" ]] && expected="1" || expected="0"
    fi
    if [[ "$type" == "float" ]]; then
        [[ "$(awk -v a="$current" -v b="$expected" 'BEGIN { print (a+0 == b+0) ? "y" : "n" }')" == "y" ]]
        return
    fi
    [[ "$current" == "$expected" ]]
}
