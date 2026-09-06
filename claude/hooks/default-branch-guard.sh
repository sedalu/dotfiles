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
# Events handled:
#   PreToolUse / Write, Edit, NotebookEdit — deny an edit that would dirty the default branch
#   PreToolUse / Bash                      — deny a git command that would lock changes onto it
#   SessionStart, CwdChanged               — report a default branch that is already dirty

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
	command=$(field '.tool_input.command // ""')
	if sets_exception_key "$command"; then
		deny "Setting $KEY exempts a checkout from the branching standard, which is a human's decision. Do not run it. Ask them to run it themselves, and say which checkout and why."
	fi
fi

# An edit is judged against the repo holding the target file, which need not be the cwd.
target=$(field '.tool_input.file_path // ""')
if [ -n "$target" ]; then
	dir=$(dirname -- "$target")
else
	dir="$cwd"
fi
[ -d "$dir" ] || dir="$cwd"
[ -d "$dir" ] || exit 0

cd "$dir" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# `--bool` normalizes every spelling git accepts for true.
allowed=$(git config --bool --get "$KEY" 2>/dev/null)
[ "$allowed" = "true" ] && exit 0

# A detached HEAD is not the default branch, and a commit there lands on no branch at all.
current=$(git branch --show-current 2>/dev/null)
[ -n "$current" ] || exit 0

[ "$current" = "$(default_branch)" ] || exit 0

remedy="Run 'git switch -c <branch>' first — uncommitted changes carry over — then retry. Exempting this checkout instead is the human's call, not yours: ask them for it rather than configuring it."

case "$event" in
PreToolUse)
	case "$tool" in
	Write | Edit | NotebookEdit)
		deny "Editing on the default branch '$current' is not permitted. $remedy"
		;;
	Bash)
		sub=$(first_locking_subcommand "$command")
		[ -n "$sub" ] && deny "'git $sub' would lock changes onto the default branch '$current'. $remedy"
		;;
	esac
	;;
SessionStart | CwdChanged)
	if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
		printf "%s has uncommitted changes on its default branch '%s'.\n" "$PWD" "$current"
		printf 'Move them onto a branch before going further: git switch -c <branch>\n'
	fi
	;;
esac

exit 0
