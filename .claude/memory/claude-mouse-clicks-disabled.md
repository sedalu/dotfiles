---
name: claude-mouse-clicks-disabled
description: Claude Code runs with CLAUDE_CODE_DISABLE_MOUSE_CLICKS=1; select text with Shift+drag in Ghostty
metadata: 
  node_type: memory
  type: project
  originSessionId: 730cb444-3e18-4719-9416-f146193cba7f
  modified: 2026-08-26T01:33:32.722Z
---

Claude Code runs in `scroll` mouse mode
via `"env": {"CLAUDE_CODE_DISABLE_MOUSE_CLICKS": "1"}` in `claude/settings.json` (commit `d7f5741`).
Text selection is **Shift+drag**, not plain drag.

**Why:** plain clicks were landing on permission prompts and the composer by accident.
`scroll` mode drops left-button press/drag but keeps wheel scrolling —
wheel events dispatch on a separate `a.name === "wheelup"/"wheeldown"` branch
that the mode's filter (`a.kind === "mouse"` + `(button & 3) === 0`) never reaches.
The only cost is Claude's own in-TUI drag-selection, which Shift+drag replaces:
Ghostty's `mouse-shift-capture` defaults to `false`
and Claude Code never sends `XTSHIFTESCAPE` to override it,
so Shift+drag does native Ghostty selection regardless of Claude's mouse mode.

**How to apply:** leave the setting in place.
Don't propose `CLAUDE_CODE_DISABLE_MOUSE=1` (`off` mode) — it kills wheel scrolling too.
Don't propose a `toggle_mouse_reporting` keybind — declined,
since a Ghostty config change is global and shouldn't be made for one app's benefit.
Settings-`env` keys reach Claude's own process only if they're on its internal allowlist;
both mouse vars are on it. See [[dotfiles-commit-to-main]].
