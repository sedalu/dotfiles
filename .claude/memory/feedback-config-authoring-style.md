---
name: feedback-config-authoring-style
description: "Authoring style in the dotfiles repo — semantic line breaks in EVERY comment (shell/TOML/pkl, not column-wrapped); no inline TOML tables"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 6717805a-7b83-4289-af3b-cb295157b81e
---

When authoring files in the dotfiles repo ([[dotfiles-commit-to-main]]), Seth
corrected me on two formatting preferences in one session (2026-06-13):

1. **No inline TOML tables.** Use standard table headers, not `{ ... }` inline
   tables. E.g. write `[dotfiles."~/.zshenv"]` with `source`/`mode` on their own
   lines, not `"~/.zshenv" = { source = "...", mode = "symlink" }`.
2. **Semantic line breaks in comments — ALL file types, not just config.**
   Break comment lines at clause/sentence boundaries (one unit of meaning per
   line), never greedy-wrapped to a fixed column width. Applies to every comment
   I write or edit here: shell, TOML, pkl, etc. Do NOT column-wrap.

**Why:** readability and clean diffs — expanded tables and clause-per-line
comments keep future edits to single-line changes.

**How to apply:** before finishing ANY comment I author in this repo, re-read it
and confirm each line ends at a clause/sentence boundary, not a wrap point. This
is a stated preference, not derivable from existing files; I have failed to
apply it after having it in memory, so treat it as a checklist item, not a hint.
