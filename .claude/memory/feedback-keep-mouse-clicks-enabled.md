---
name: feedback-keep-mouse-clicks-enabled
description: Don't disable Claude Code mouse clicks — the tradeoffs were tried and rejected
metadata:
  type: feedback
---

Leave Claude Code's mouse handling at its default.
`CLAUDE_CODE_DISABLE_MOUSE_CLICKS=1` was set in `claude/settings.json` on 2026-08-25
and reverted on 2026-08-26.

**Why:** `scroll` mouse mode stopped stray clicks from landing on permission prompts,
but it also swallowed every other click:
collapsed tool-use output and other collapsed context can no longer be expanded,
which costs more than the accidental clicks did.
`CLAUDE_CODE_DISABLE_MOUSE=1` (`off` mode) is strictly worse — it kills wheel scrolling too.

**How to apply:** don't re-propose either mouse env var,
or a Ghostty `toggle_mouse_reporting` keybind (declined earlier —
a Ghostty config change is global and shouldn't be made for one app's benefit).
Shift+drag remains the way to do native Ghostty text selection over Claude's TUI.
See [[dotfiles-commit-to-main]].
