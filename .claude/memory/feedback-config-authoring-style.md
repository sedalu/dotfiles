---
name: feedback-config-authoring-style
description: "Authoring style — semantic line breaks in Markdown prose AND every comment type (not column-wrapped), now codified in global CLAUDE.md; no inline TOML tables in the dotfiles repo"
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
2. **Semantic line breaks — Markdown prose AND ALL comment types.**
   Break at clause/sentence boundaries (one unit of meaning per line), never
   greedy-wrapped to a fixed column width. Applies to Markdown prose and to every
   comment I write or edit: shell, TOML, pkl, etc. Do NOT column-wrap.
   **My recurring failure (caught repeatedly, incl. 2026-07-02/04):** I write a long
   subject phrase, hit an imagined column limit, and wrap right before the verb —
   e.g. `# ...and the claude cask\n# are managed by mise`. NEVER split a subject from
   its verb. A subject+verb+object is ONE clause = ONE line, however long it runs.
   Only break before conjunctions (and/but/so/or), before subordinate clauses, and
   after colons/semicolons/dashes.

As of 2026-06-16 this is codified as a global authoring default in
`~/.claude/CLAUDE.md` ("## Authoring Style: Semantic Line Breaks"), and the whole
dotfiles repo (all owned Markdown + comments) was reflowed to conform. Exceptions
left greedy on purpose: generated `macos/settings.sh` descriptions (verbatim from
macos-defaults.com via `catalog:macos`), `#USAGE`/`#MISE` spec strings, shellcheck
directives, and column-aligned tables.

**Why:** readability and clean diffs — clause-per-line prose and comments keep
future edits to single-line changes.

**How to apply:** before finishing ANY prose or comment I author here, re-read it
and confirm each line ends at a clause/sentence boundary, not a wrap point. I have
failed to apply it after having it in memory, so treat it as a checklist item, not
a hint.
