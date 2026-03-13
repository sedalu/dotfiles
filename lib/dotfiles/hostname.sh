# lib/dotfiles/hostname.sh — hostname utilities

# get_hostname — returns the short hostname for this machine.
# On macOS, uses scutil --get LocalHostName (avoids the .local FQDN).
# On Linux, uses hostname.
get_hostname() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    scutil --get LocalHostName 2>/dev/null || hostname
  else
    hostname
  fi
}

normalize_hostname() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/--*/-/g;s/^-//;s/-$//'
}
