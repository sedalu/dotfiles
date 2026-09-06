# shellcheck shell=bash
# lib/claude-hooks.sh — shared helpers for the guards in claude/hooks/
#
# Sourced, never executed.
# Every hook reads one JSON payload on stdin, decides, and exits 0:
# a block is expressed through the JSON on stdout, never through the exit status,
# so a hook that fails lets the tool call through rather than wedging the session.

# Reads a field out of the payload the caller left in $payload.
# shellcheck disable=SC2154  # payload is set by the sourcing hook, after it reads stdin
field() {
	printf '%s' "$payload" | jq -r "$1" 2>/dev/null || true
}

deny() {
	jq -n --arg reason "$1" '{
		hookSpecificOutput: {
			hookEventName: "PreToolUse",
			permissionDecision: "deny",
			permissionDecisionReason: $reason
		}
	}'
	exit 0
}

ask() {
	jq -n --arg reason "$1" '{
		hookSpecificOutput: {
			hookEventName: "PreToolUse",
			permissionDecision: "ask",
			permissionDecisionReason: $reason
		}
	}'
	exit 0
}

# Prints the default branch of the repo at $1 (default: the cwd).
# origin/HEAD is authoritative; the rest are for a clone that has never had it set.
default_branch() {
	local dir=${1:-.} ref candidate
	ref=$(git -C "$dir" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
	if [ -n "$ref" ]; then
		printf '%s\n' "${ref#origin/}"
		return
	fi
	for candidate in main master; do
		if git -C "$dir" show-ref --verify --quiet "refs/heads/$candidate"; then
			printf '%s\n' "$candidate"
			return
		fi
	done
	ref=$(git -C "$dir" config --get init.defaultBranch 2>/dev/null)
	printf '%s\n' "${ref:-main}"
}

# Prints the toplevel when $1 sits in a worktree project's main checkout, else returns 1.
# The checkout is named `main` and its `.git` is a directory;
# a linked worktree's `.git` is a file holding a gitdir: pointer,
# so a sibling that merely happens to be named `main` does not match.
# Same discriminator lib/worktree.sh uses to find a project.
main_checkout() {
	local top
	top=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null) || return 1
	[ -n "$top" ] || return 1
	[ "${top##*/}" = main ] || return 1
	[ -d "$top/.git" ] || return 1
	printf '%s\n' "$top"
}

# Walks each git invocation in a command line and reports the directory it acts on,
# a tab, then its subcommand and arguments.
# Splitting on shell separators keeps the invocations in a compound command apart,
# and git's own options are stepped over to reach the subcommand.
# -C is the one option kept rather than discarded:
# it names the directory the invocation acts on, which is not always the cwd.
# Repeated -C compose the way git composes them, each relative to the last.
#
# Split a line with `invocation_dir` and `invocation_cmd`, never with `IFS=$'\t' read`:
# tab is IFS whitespace, so read would swallow the empty directory field
# and shift the subcommand into it.
git_invocations() {
	local cmd=$1 segment cdir i n
	local -a tok
	while IFS= read -r segment; do
		read -r -a tok <<<"$segment"
		i=0
		n=${#tok[@]}
		while [ "$i" -lt "$n" ]; do
			if [ "${tok[i]}" = "git" ]; then
				cdir=""
				i=$((i + 1))
				while [ "$i" -lt "$n" ]; do
					case "${tok[i]}" in
					-C)
						if [ $((i + 1)) -lt "$n" ]; then
							case "${tok[i + 1]}" in
							/*) cdir="${tok[i + 1]}" ;;
							*) cdir="${cdir:+$cdir/}${tok[i + 1]}" ;;
							esac
						fi
						i=$((i + 2))
						;;
					-c | --git-dir | --work-tree) i=$((i + 2)) ;;
					-*) i=$((i + 1)) ;;
					*) break ;;
					esac
				done
				[ "$i" -lt "$n" ] && printf '%s\t%s\n' "$cdir" "${tok[*]:i}"
			fi
			i=$((i + 1))
		done
	done < <(printf '%s\n' "$cmd" | tr ';|&' '\n')
}

# The two halves of a git_invocations line.
invocation_dir() { printf '%s\n' "${1%%$'\t'*}"; }
invocation_cmd() { printf '%s\n' "${1#*$'\t'}"; }

# Subcommands that write a commit onto the current branch.
# `switch`, `checkout`, `stash`, `restore`, `reset`, and `clean` are absent on purpose:
# each one moves work off the default branch or discards it, which is the way out of there.
locking=" commit merge rebase am cherry-pick revert "

# Prints the locking subcommand of one invocation, or returns 1.
locking_subcommand() {
	local sub word operands=0
	local -a args
	read -r -a args <<<"$1"
	sub=${args[0]:-}
	[ -n "$sub" ] || return 1
	if [[ $locking == *" $sub "* ]]; then
		printf '%s\n' "$sub"
		return 0
	fi
	# A bare `git push` publishes the current branch.
	# An explicit remote and refspec names what to push,
	# so pushing a feature branch while standing on another is legitimate.
	if [ "$sub" = push ]; then
		for word in "${args[@]:1}"; do
			case "$word" in
			-*) ;;
			*) operands=$((operands + 1)) ;;
			esac
		done
		if [ "$operands" -lt 2 ]; then
			printf 'push\n'
			return 0
		fi
	fi
	return 1
}

# Prints the first locking subcommand anywhere in a command line, or returns 1.
first_locking_subcommand() {
	local line sub
	while IFS= read -r line; do
		if sub=$(locking_subcommand "$(invocation_cmd "$line")"); then
			printf '%s\n' "$sub"
			return 0
		fi
	done < <(git_invocations "$1")
	return 1
}
