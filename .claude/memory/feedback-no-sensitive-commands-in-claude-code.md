---
name: feedback-no-sensitive-commands-in-claude-code
description: "Never route password/secret-entry commands through Claude Code's `!` prefix — the user runs those in their own terminal"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 36186a78-3fba-4f60-b8a6-9882a81ddb8e
  modified: 2026-08-16T02:17:51.499Z
---

The user does not enter sensitive commands inside Claude Code.
Anything that prompts for a password — `sudo` over ssh, `fnox set`, `smbpasswd`, a login flow —
gets run in their own terminal, and the output pasted back if it matters.

**Why:** secrets typed at the `!` prefix pass through the agent session.
It is a standing boundary, not a per-case preference.

**How to apply:** never suggest `! <command>` for anything that will prompt for a credential.
Hand over the exact command to run in their terminal instead, and say what output to paste back.
When debugging an interactive-terminal failure, do not treat the `!` prefix as a variable to test —
they were never using it.
See [[feedback-store-all-passwords-in-fnox]].
