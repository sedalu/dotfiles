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

# A relative path would resolve against ~/.claude, which is a symlink into this tree,
# so the library is reached through the same variable the mise tasks use.
# shellcheck source=SCRIPTDIR/../../lib/claude-hooks.sh
source "${DOTFILES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}}/lib/claude-hooks.sh" || exit 0

payload=$(cat)

event=$(field '.hook_event_name // ""')
tool=$(field '.tool_name // ""')
[ "$event" = PreToolUse ] && [ "$tool" = Bash ] || exit 0

command=$(field '.tool_input.command // ""')
[ -n "$command" ] || exit 0

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

# `-n` is --no-verify on commit, but --dry-run on push,
# so the short form is only a bypass under commit.
while IFS= read -r line; do
	read -r -a args <<<"$(invocation_cmd "$line")"
	[ "${args[0]:-}" = commit ] || continue
	for word in "${args[@]:1}"; do
		case "$word" in
		--*) ;;
		-*n*) ask "'git commit $word' carries -n (--no-verify), which skips the git hooks. $remedy" ;;
		esac
	done
done < <(git_invocations "$command")

exit 0
