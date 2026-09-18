#!/usr/bin/env bash
# Keep a worktree project's main checkout on its default branch, and keep work out of it.
#
# A worktree project is a directory of sibling checkouts:
# `main/` is a normal clone holding the git directory,
# and each branch is a linked worktree beside it.
# `main/` is the anchor and is never worked in,
# so work starts with `mise run worktree:branch <branch>`,
# not with a branch switch in place.
#
# default-branch-guard.sh cannot express this and defers here.
# It allows `switch` and `checkout` on purpose,
# since moving off the default branch is its remedy;
# in the main checkout that same move is the violation.
# It is also blind to the aftermath:
# once the main checkout is off the default branch, or on a detached HEAD,
# that hook short-circuits and stops guarding the directory at all.
# So this hook denies work in the main checkout on *any* branch,
# not only the default one.
#
# Denial rather than a prompt:
# the layout is the whole reason the project has a `main/`,
# and there is nothing for a human to grant —
# the sibling worktree is always available.
#
# Deliberately not blocked: `reset`, `restore`, `stash`, `clean`.
# They change content or where a branch points,
# never which branch the checkout is on.
#
# The Bash branch reads git invocations, which is the most it can do.
# A write reaches the filesystem through `sed -i`, a redirect,
# or a heredoc fed to any interpreter,
# and no amount of parsing a command line enumerates those.
# So prevention stops at the commands that can be named,
# and PostToolUse is the half with full coverage:
# it reads the checkout rather than the command,
# and sees the write whatever made it.
# It cannot deny, because by then the write has happened —
# it makes sure the agent and the human are told while git can still undo it.
#
# Events handled:
#   PreToolUse / Write, Edit, NotebookEdit — deny an edit to a file in the main checkout
#   PreToolUse / Bash                      — deny a command that moves its HEAD or commits in it
#   PostToolUse / Bash                     — report a main checkout left dirty or off its branch
#   SessionStart, CwdChanged               — report the main checkout's state

# No `-e`: a probe that fails must let the tool call through rather than block on a hook bug.
set -uo pipefail

# A relative path would resolve against ~/.claude, which is a symlink into this tree,
# so the library is reached through the same variable the mise tasks use.
# shellcheck source=SCRIPTDIR/../../lib/claude-hooks.sh
source "${DOTFILES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}}/lib/claude-hooks.sh" || exit 0

payload=$(cat)

event=$(field '.hook_event_name // ""')
tool=$(field '.tool_name // ""')
cwd=$(field '.cwd // ""')

remedy="Run 'mise run worktree:branch <branch>' and work in the sibling worktree it creates."

# Resolves an invocation's -C operand against the session cwd.
resolve_dir() {
	case "$1" in
	"") printf '%s\n' "$cwd" ;;
	/*) printf '%s\n' "$1" ;;
	*) printf '%s\n' "$cwd/$1" ;;
	esac
}

# Describes how an invocation would take the checkout off its default branch, or returns 1.
# $1 the checkout,
# $2 its default branch,
# $3 the directory the invocation runs in,
# $4 the invocation.
moves_head() {
	local top=$1 db=$2 dir=$3 sub word first="" old prev
	local -a args ops=()
	read -r -a args <<<"$4"
	sub=${args[0]:-}

	# A rename leaves HEAD where it is,
	# but takes the default branch's name off it.
	if [ "$sub" = branch ]; then
		local move=0
		for word in "${args[@]:1}"; do
			case "$word" in
			-m | -M | --move) move=1 ;;
			-*) ;;
			*) ops+=("$word") ;;
			esac
		done
		[ "$move" = 1 ] || return 1
		if [ "${#ops[@]}" -ge 2 ]; then
			old=${ops[0]}
		else
			old=$(git -C "$top" branch --show-current 2>/dev/null)
		fi
		[ "$old" = "$db" ] || return 1
		printf "would rename the default branch '%s'\n" "$db"
		return 0
	fi

	case "$sub" in
	switch | checkout) ;;
	*) return 1 ;;
	esac

	for word in "${args[@]:1}"; do
		case "$word" in
		# Everything past `--` is a pathspec,
		# and no form of it moves HEAD.
		--) return 1 ;;
		-b | -B | -c | -C | --create | --force-create)
			printf 'would create a branch and move HEAD onto it\n'
			return 0
			;;
		-d | --detach)
			# A detached HEAD also blinds default-branch-guard.sh,
			# which reads `git branch --show-current` and allows when it comes back empty.
			printf 'would detach HEAD\n'
			return 0
			;;
		--orphan)
			printf 'would move HEAD onto a new rootless branch\n'
			return 0
			;;
		-)
			# `-` is the previously checked-out branch,
			# which may well be the default one when the checkout is being restored,
			# so judge it by what it resolves to.
			prev=$(git -C "$dir" rev-parse --abbrev-ref '@{-1}' 2>/dev/null)
			[ -n "$first" ] || first=${prev:--}
			;;
		-*) ;;
		*) [ -n "$first" ] || first=$word ;;
		esac
	done

	# `git switch` alone, or back onto the default branch, is the way out of a bad state.
	[ -n "$first" ] || return 1
	[ "$first" = "$db" ] && return 1

	# `git switch` takes no pathspec,
	# so its operand is always a branch.
	# `git checkout` is ambiguous,
	# and an existing path restores files without moving HEAD.
	if [ "$sub" = checkout ] && [ -e "$dir/$first" ]; then
		return 1
	fi

	printf "would move HEAD onto '%s'\n" "$first"
}

# Describes how the main checkout at $1 has left its resting state, or returns 1.
# Resting is the default branch, with nothing uncommitted.
main_checkout_fault() {
	local top=$1 db current
	db=$(default_branch "$top")
	current=$(git -C "$top" branch --show-current 2>/dev/null)
	if [ -z "$current" ]; then
		printf "It is on a detached HEAD rather than '%s'; restore it with 'git switch %s'." "$db" "$db"
		return 0
	fi
	if [ "$current" != "$db" ]; then
		printf "It is on '%s' rather than '%s'; restore it with 'git switch %s'." "$current" "$db" "$db"
		return 0
	fi
	if [ -n "$(git -C "$top" status --porcelain 2>/dev/null)" ]; then
		printf "It has uncommitted changes; move them out with 'git stash', then 'git stash pop' in the sibling."
		return 0
	fi
	return 1
}

case "$event" in
PreToolUse)
	case "$tool" in
	Write | Edit | NotebookEdit)
		target=$(field '.tool_input.file_path // ""')
		[ -n "$target" ] || exit 0
		dir=$(dirname -- "$target")
		[ -d "$dir" ] || exit 0
		top=$(main_checkout "$dir") || exit 0
		deny "'$top' is a worktree project's main checkout: it holds the git directory and is never worked in. $remedy"
		;;
	Bash)
		command=$(field '.tool_input.command // ""')
		[ -n "$command" ] || exit 0
		while IFS= read -r line; do
			dir=$(resolve_dir "$(invocation_dir "$line")")
			[ -d "$dir" ] || continue
			top=$(main_checkout "$dir") || continue
			invocation=$(invocation_cmd "$line")

			db=$(default_branch "$top")
			if effect=$(moves_head "$top" "$db" "$dir" "$invocation"); then
				deny "'git $invocation' $effect in the main checkout '$top', which must stay on '$db'. $remedy"
			fi

			# Sealed on every branch,
			# so a checkout already dragged off the default branch is not the one place an agent may freely commit.
			if sub=$(locking_subcommand "$invocation"); then
				deny "'git $sub' would commit in the main checkout '$top', which is never worked in. $remedy"
			fi
		done < <(git_invocations "$command")
		;;
	esac
	;;
PostToolUse)
	# Judged from the session cwd rather than the command,
	# so a sibling worktree reaches the same main checkout and a write from anywhere in the project is seen.
	[ "$tool" = Bash ] || exit 0
	[ -n "$cwd" ] && [ -d "$cwd" ] || exit 0
	top=$(project_main_checkout "$cwd") || exit 0
	fault=$(main_checkout_fault "$top") || exit 0
	warn "'$top' is a worktree project's main checkout and is never worked in, but it is not in its resting state. $fault $remedy"
	;;
SessionStart | CwdChanged)
	[ -n "$cwd" ] && [ -d "$cwd" ] || exit 0
	top=$(main_checkout "$cwd") || exit 0
	if fault=$(main_checkout_fault "$top"); then
		printf "%s is this worktree project's main checkout, and is not in its resting state.\n" "$top"
		printf "%s %s\n" "$fault" "$remedy"
	else
		printf "%s is this worktree project's main checkout: it holds the git directory and is not worked in. Start work with 'mise run worktree:branch <branch>'.\n" "$top"
	fi
	;;
esac

exit 0
