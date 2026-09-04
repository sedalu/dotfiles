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

KEY=defaultBranch.allowDirectCommits

payload=$(cat)

field() {
	printf '%s' "$payload" | jq -r "$1" 2>/dev/null || true
}

event=$(field '.hook_event_name // ""')
tool=$(field '.tool_name // ""')
cwd=$(field '.cwd // ""')

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

# Walks each git invocation in a command line and reports its subcommand plus its arguments.
# Splitting on shell separators keeps the invocations in a compound command apart,
# and git's own options are stepped over to reach the subcommand.
git_invocations() {
	local cmd=$1 segment i n
	local -a tok
	while IFS= read -r segment; do
		read -r -a tok <<<"$segment"
		i=0
		n=${#tok[@]}
		while [ "$i" -lt "$n" ]; do
			if [ "${tok[i]}" = "git" ]; then
				i=$((i + 1))
				while [ "$i" -lt "$n" ]; do
					case "${tok[i]}" in
					-C | -c | --git-dir | --work-tree) i=$((i + 2)) ;;
					-*) i=$((i + 1)) ;;
					*) break ;;
					esac
				done
				[ "$i" -lt "$n" ] && printf '%s\n' "${tok[*]:i}"
			fi
			i=$((i + 1))
		done
	done < <(printf '%s\n' "$cmd" | tr ';|&' '\n')
}

# True when a command would write the opt-out key.
# Reading it and removing it are both fine — only granting the exception is gated.
sets_exception_key() {
	local invocation
	while IFS= read -r invocation; do
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

# Subcommands that write a commit onto the current branch.
# `switch`, `checkout`, `stash`, `restore`, `reset`, and `clean` are absent on purpose:
# each one moves work off the default branch or discards it, which is the way out of here.
locking=" commit merge rebase am cherry-pick revert "

first_locking_subcommand() {
	local invocation sub args word
	while IFS= read -r invocation; do
		read -r -a args <<<"$invocation"
		sub=${args[0]}
		if [[ $locking == *" $sub "* ]]; then
			printf '%s\n' "$sub"
			return 0
		fi
		# A bare `git push` publishes the current branch.
		# An explicit remote and refspec names what to push,
		# so pushing a feature branch while standing here is legitimate.
		if [ "$sub" = push ]; then
			local operands=0
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

default_branch() {
	local ref candidate
	ref=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
	if [ -n "$ref" ]; then
		printf '%s\n' "${ref#origin/}"
		return
	fi
	for candidate in main master; do
		if git show-ref --verify --quiet "refs/heads/$candidate"; then
			printf '%s\n' "$candidate"
			return
		fi
	done
	ref=$(git config --get init.defaultBranch 2>/dev/null)
	printf '%s\n' "${ref:-main}"
}

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
