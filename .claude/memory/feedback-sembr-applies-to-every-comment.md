---
name: feedback-sembr-applies-to-every-comment
description: "Semantic line breaks are enforced in every comment, including two-line ones in TOML and shell; the user rejects edits that wrap instead"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 36186a78-3fba-4f60-b8a6-9882a81ddb8e
  modified: 2026-08-16T00:55:37.656Z
---

Semantic line breaks are not just for prose files.
The user rejects edits — mid-tool-call, with a one-word "SEMBR!" — when a **two-line comment**
in `mise.toml` or a shell script breaks at a wrap point rather than a clause boundary.

**Why:** the rule in the global CLAUDE.md says "Markdown prose and comments in every file type",
and it means it. Short comments are where the habit slips, because wrapping one clause across
two lines looks harmless. It still reads as a violation to them.

**How to apply:** break before `so`, `and`, `where`, `which`, `since`, and after a colon.
Let a line run long rather than wrapping a clause. Before finishing any comment, re-read it and
confirm each line ends where a clause does. Audit the short ones hardest — a four-line block
comment usually survives; the two-liner is the one that gets rejected.

Related: [[feedback-no-meta-commentary-in-tasks]], [[feedback-no-history-comments]],
[[feedback-config-authoring-style]].
