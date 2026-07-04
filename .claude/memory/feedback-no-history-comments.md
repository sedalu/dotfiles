---
name: feedback-no-history-comments
description: "Don't write changelog/history comments in code that narrate what moved or changed between versions"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 12706bd3-18dd-4bf6-bbbf-e6ce8e9c4225
---

Never leave "history" comments in code —
comments that narrate what changed, moved, or when
(e.g. "moved to X in mise 2026.7.0, PR #10671", "was cp -R, now ditto").
The user calls these pointless.

**Why:** git history already records what changed and when;
a comment restating it is noise that goes stale.
Comments should explain why the current code is the way it is, not its edit history.

**How to apply:** when removing/relocating code, delete it cleanly with no "moved to …" breadcrumb.
Only add a comment if it explains present rationale a reader needs.
Related: [[feedback-config-authoring-style]].
