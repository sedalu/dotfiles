# shellcheck shell=bash
# lib/worktree.sh — locating a worktree project and its checkouts

# Sets MAIN (the main checkout, which holds the git directory) and ROOT (its parent).
# Returns 1 outside a worktree project.
worktree_root() {
	# mise rewrites PWD to the config root, so the original cwd is what we walk up from.
	local dir="${MISE_ORIGINAL_CWD:-$PWD}"
	while [ "$dir" != "/" ]; do
		# A main checkout's .git is a directory;
		# a linked worktree's is a file holding a gitdir: pointer.
		if [ -d "$dir/main/.git" ]; then
			MAIN="$dir/main"
			# shellcheck disable=SC2034  # ROOT consumed by the worktree:* tasks and mise/bin/lazygit
			ROOT="$dir"
			return 0
		fi
		dir=$(dirname "$dir")
	done
	return 1
}

# Emits one worktree path per line. Requires MAIN.
list_worktrees() {
	# sed rather than awk $2, so a path containing spaces survives.
	git -C "$MAIN" worktree list --porcelain | sed -n 's/^worktree //p'
}
