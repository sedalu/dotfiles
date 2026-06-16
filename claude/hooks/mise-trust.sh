#!/usr/bin/env bash
# Auto-trust mise configs in known git repos/worktrees.
#
# Security model:
#   - Main worktree: only trust if config content is already in the mise trust store
#     (i.e. the user previously reviewed and trusted it manually).
#   - Secondary worktree: only trust if the main worktree's config is trusted.
#   - Non-git directories: never auto-trust.
#
# This prevents blindly trusting configs in newly-cloned or unknown repos.
# The first trust of any repo must be done manually with `mise trust`.

set -euo pipefail

TRUSTED_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/mise/trusted-configs"

# Must be in a git repo
git_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0

# Get the main worktree path (first entry from git worktree list)
main_worktree=$(git worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2; exit}')
[ -z "$main_worktree" ] && exit 0

# All locations mise searches for config files (relative to a directory root)
MISE_CONFIGS=(
	"mise.toml"
	"mise.local.toml"
	".mise.toml"
	"mise/config.toml"
	".mise/config.toml"
	".config/mise.toml"
	".config/mise/config.toml"
)

# Returns 0 if any mise config in DIR has its exact content in the trust store.
# mise stores trusted configs as copies, so content-matching is reliable.
is_trusted() {
	local dir="$1"
	[ -d "$TRUSTED_DIR" ] || return 1
	for rel in "${MISE_CONFIGS[@]}"; do
		local path="$dir/$rel"
		[ -f "$path" ] || continue
		local hash
		hash=$(shasum -a 256 "$path" 2>/dev/null | awk '{print $1}')
		[ -z "$hash" ] && continue
		if find "$TRUSTED_DIR" -type f -exec shasum -a 256 {} \; 2>/dev/null |
			grep -q "^$hash"; then
			return 0
		fi
	done
	return 1
}

if [ "$git_root" = "$main_worktree" ]; then
	# Main worktree: only trust if this config was previously trusted by the user
	is_trusted "$git_root" && mise trust -y --quiet 2>/dev/null || true
else
	# Secondary worktree: only trust if the main worktree's config is trusted
	is_trusted "$main_worktree" && mise trust -y --quiet 2>/dev/null || true
fi
