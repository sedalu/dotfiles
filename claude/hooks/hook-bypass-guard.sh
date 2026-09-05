#!/usr/bin/env bash
# Ask before a command bypasses the hk pipeline.
#
# Two bypasses exist:
#   HK=0        — the gate every `hook` entry in git/config tests (`test "${HK:-1}" = "0"`)
#   --no-verify — git's own, which skips the hook before hk is reached
#
# Bypassing is for a broken hook, not a failing or a slow check,
# so the decision is handed to the human rather than taken by the agent.
# The decision is "ask" rather than "deny":
# a genuinely broken hook still has a way past, it just is not the agent's call.
#
# Events handled:
#   PreToolUse / Bash — ask before a command carrying either bypass

# No `-e`: a probe that fails must let the tool call through rather than block on a hook bug.
set -uo pipefail

payload=$(cat)

field() {
	printf '%s' "$payload" | jq -r "$1" 2>/dev/null || true
}

event=$(field '.hook_event_name // ""')
tool=$(field '.tool_name // ""')
[ "$event" = PreToolUse ] && [ "$tool" = Bash ] || exit 0

command=$(field '.tool_input.command // ""')
[ -n "$command" ] || exit 0

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

remedy="Bypassing is for a broken hook, not a failing or a slow one. Run the command without it. If a hook is genuinely broken, say so and hand the bypass to the human rather than running it."

# Shell separators become whitespace, so each token stands alone
# and a bypass in any command of a compound line is still seen.
read -r -a tokens <<<"$(printf '%s' "$command" | tr ';|&()' '      ')"

for token in "${tokens[@]}"; do
	case "$token" in
	HK=0)
		ask "HK=0 skips the hk pipeline. $remedy"
		;;
	--no-verify)
		ask "--no-verify skips the git hooks. $remedy"
		;;
	esac
done

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

# `-n` is --no-verify on commit, but --dry-run on push,
# so the short form is only a bypass under commit.
while IFS= read -r invocation; do
	read -r -a args <<<"$invocation"
	[ "${args[0]:-}" = commit ] || continue
	for word in "${args[@]:1}"; do
		case "$word" in
		--*) ;;
		-*n*) ask "'git commit $word' carries -n (--no-verify), which skips the git hooks. $remedy" ;;
		esac
	done
done < <(git_invocations "$command")

exit 0
