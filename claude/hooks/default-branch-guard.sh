#!/usr/bin/env bash
# Enforce the branching standard: work happens on a branch, never the default branch.
#
# The opt-out is `defaultBranch.allowDirectCommits` in a checkout's local git config.
# It is per-clone and never committed,
# so one checkout can permit direct commits
# while every other checkout of the same repo still branches.
#
# Setting that key is denied outright:
# an agent that could grant itself the exception is not gated by it,
# so the command is handed to the human to run.
#
# A worktree project's main checkout is not this hook's to police:
# leaving the default branch there is the violation rather than the remedy,
# so main-checkout-guard.sh owns that directory and this one defers.
#
# The Bash branch reads git invocations,
# so a write made by `sed -i`, a redirect, or a heredoc fed to an interpreter
# reaches the default branch unseen.
# PostToolUse closes that by reading the checkout rather than the command.
# It cannot deny, because the write has happened —
# it makes sure the change is noticed while it is still one `git switch -c` from being correct.
#
# Every event judges the checkout that is actually being touched:
# the repo holding an edit's target file,
# the directory each git invocation acts on,
# and, after a command runs, every repo any path in it reached.
# The session cwd is only the starting point,
# never the thing being judged on its own.
#
# Events handled:
#   PreToolUse / Write, Edit, NotebookEdit — deny an edit that would dirty a default branch
#   PreToolUse / Bash                      — deny a git command that would lock changes onto one
#   PostToolUse / Bash                     — report a default branch the command dirtied
#   SessionStart, CwdChanged               — report the cwd's default branch if it is already dirty

# No `-e`: a probe that fails must let the tool call through rather than block on a hook bug.
set -uo pipefail

# A relative path would resolve against ~/.claude, which is a symlink into this tree,
# so the library is reached through the same variable the mise tasks use.
# shellcheck source=SCRIPTDIR/../../lib/claude-hooks.sh
source "${DOTFILES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}}/lib/claude-hooks.sh" || exit 0

KEY=defaultBranch.allowDirectCommits

payload=$(cat)

event=$(field '.hook_event_name // ""')
tool=$(field '.tool_name // ""')
cwd=$(field '.cwd // ""')
command=$(field '.tool_input.command // ""')

# True when a command would write the opt-out key.
# Reading it and removing it are both fine — only granting the exception is gated.
sets_exception_key() {
	local line invocation
	while IFS= read -r line; do
		invocation=$(invocation_cmd "$line")
		case "$invocation" in
		config\ *) ;;
		*) continue ;;
		esac
		case "$invocation" in
		*"$KEY"*) ;;
		*) continue ;;
		esac
		case "$invocation" in
		*--get* | *--list* | *--unset*) continue ;;
		esac
		return 0
	done < <(git_invocations "$1")
	return 1
}

# The exception gate is checked before anything else,
# so it holds outside a repo and in a checkout that already has the key set.
if [ "$event" = PreToolUse ] && [ "$tool" = Bash ]; then
	if sets_exception_key "$command"; then
		deny "Setting $KEY exempts a checkout from the branching standard, which is a human's decision. Do not run it. Ask them to run it themselves, and say which checkout and why."
	fi
fi

remedy="Run 'git switch -c <branch>' first — uncommitted changes carry over — then retry. Exempting this checkout instead is the human's call, not yours: ask them for it rather than configuring it."

# Prints the toplevel when $1 sits in a checkout this hook guards, else returns 1.
# Guarded means a repo that is not a worktree project's main checkout,
# has not been granted the local exception,
# and is standing on its default branch.
guarded_checkout() {
	local dir=$1 top allowed current
	top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || return 1
	[ -n "$top" ] || return 1

	# A worktree project's main checkout belongs to main-checkout-guard.sh, on every event.
	# That hook pins the branch and seals the checkout,
	# and its remedy is `worktree:branch` rather than the `git switch -c` this one prints.
	main_checkout "$top" >/dev/null 2>&1 && return 1

	# `--bool` normalizes every spelling git accepts for true.
	allowed=$(git -C "$top" config --bool --get "$KEY" 2>/dev/null)
	[ "$allowed" = "true" ] && return 1

	# A detached HEAD is not the default branch, and a commit there lands on no branch at all.
	current=$(git -C "$top" branch --show-current 2>/dev/null)
	[ -n "$current" ] || return 1
	[ "$current" = "$(default_branch "$top")" ] || return 1

	printf '%s\n' "$top"
}

case "$event" in
PreToolUse)
	case "$tool" in
	Write | Edit | NotebookEdit)
		# An edit is judged against the repo holding the target file, which need not be the cwd.
		target=$(field '.tool_input.file_path // ""')
		if [ -n "$target" ]; then
			dir=$(dirname -- "$target")
		else
			dir="$cwd"
		fi
		[ -d "$dir" ] || dir="$cwd"
		[ -d "$dir" ] || exit 0
		top=$(guarded_checkout "$dir") || exit 0
		deny "Editing on the default branch '$(default_branch "$top")' in '$top' is not permitted. $remedy"
		;;
	Bash)
		# Each invocation is judged against the directory it acts on,
		# so a `git -C`, or a `cd` into another repo, is judged against that repo rather than the cwd.
		while IFS= read -r line; do
			sub=$(locking_subcommand "$(invocation_cmd "$line")") || continue
			dir=$(resolve_dir "$(invocation_dir "$line")" "$cwd")
			[ -d "$dir" ] || continue
			top=$(guarded_checkout "$dir") || continue
			deny "'git $sub' would lock changes onto the default branch '$(default_branch "$top")' in '$top'. $remedy"
		done < <(git_invocations "$command")
		;;
	esac
	;;
PostToolUse)
	# Judged against every directory the command named, not against the session cwd,
	# so a write into a repo the session never stood in is seen too.
	[ "$tool" = Bash ] || exit 0
	seen=""
	while IFS= read -r dir; do
		top=$(guarded_checkout "$dir") || continue
		case "$seen" in *"|$top|"*) continue ;; esac
		seen="$seen|$top|"
		[ -n "$(git -C "$top" status --porcelain 2>/dev/null)" ] || continue
		warn "The default branch '$(default_branch "$top")' in '$top' now has uncommitted changes, and work does not happen on it. Move them onto a branch — 'git switch -c <branch>' carries them over. Exempting this checkout instead is the human's call, not yours: ask them for it rather than configuring it."
	done < <(command_dirs "$command" "$cwd")
	;;
SessionStart | CwdChanged)
	[ -n "$cwd" ] && [ -d "$cwd" ] || exit 0
	top=$(guarded_checkout "$cwd") || exit 0
	if [ -n "$(git -C "$top" status --porcelain 2>/dev/null)" ]; then
		printf "%s has uncommitted changes on its default branch '%s'.\n" "$top" "$(default_branch "$top")"
		printf 'Move them onto a branch before going further: git switch -c <branch>\n'
	fi
	;;
esac

exit 0
