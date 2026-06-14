---
name: feedback-config-authoring-style
description: "How Seth wants config/code authored in the dotfiles repo — no inline TOML tables, semantic line breaks in comments"
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
2. **Semantic line breaks in comments.** Break comment lines at clause/sentence
   boundaries (one unit of meaning per line), not greedy-wrapped to a fixed
   column width. Applies to code comments (shell, TOML).

**Why:** readability and clean diffs — expanded tables and clause-per-line
comments keep future edits to single-line changes.

**How to apply:** match this whenever I write or edit TOML and commented code
here; it's a stated style preference, not derivable from existing files alone.
