---
name: feedback-hand-off-commands-last
description: Only give the user a command to run when all other work is finished — it must be the last thing in the message
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 36186a78-3fba-4f60-b8a6-9882a81ddb8e
  modified: 2026-08-17T02:52:21.816Z
---

Never hand the user a command to run and then keep working.
Finish every other edit, check, and commit first,
then give the command as the final thing in the message, with nothing after it.

**Why:** the user is not going to scroll back to hunt for it.
A command followed by more tool calls and more output is effectively lost,
and asking them to find it again wastes their time.

**How to apply:** before writing a command for the user to run, ask whether there is
any remaining work in this turn. If there is, do it first.
When the command finally appears, it goes last — no further tool calls, no trailing commentary.
Applies especially to sudo-prompting commands, which must be handed over rather than run.
See [[feedback-no-sensitive-commands-in-claude-code]].
