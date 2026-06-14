---
name: feedback_macos_defaults_session
description: Feedback from the macos-defaults-diff skill creation session — workflow approach and project skill location
metadata:
  type: feedback
---

Use `defaults read > file` for snapshots (one file per snapshot, not per-domain). Then `diff before after` for comparison. Add a noise-filter pass before showing to Claude for analysis. Raw diff is too noisy to be useful on its own — the analysis pass is essential.

**Why:** `defaults read` with no args dumps ALL domains at once. A simple text diff between two such snapshots is the simplest correct approach. Per-domain directory-based approaches are unnecessarily complex.

**How to apply:** For any macOS defaults capture workflow, use `defaults read > file` + `diff`. Don't use per-domain plist directories or JSON conversion.

---

Project skills (available only within a project) live in `<project-dir>/.claude/skills/<skill-name>/SKILL.md`. For the dotfiles project, that's `~/.config/.claude/skills/<skill-name>/SKILL.md`. Do NOT put project skills in `~/.config/claude/skills/` (that's the global user config dir, not a project skills dir).

**Why:** The user corrected this during the session. `~/.config/claude/` is the global Claude config (symlinked from `~/.claude/`). Project skills belong in `<project>/.claude/skills/`.

**How to apply:** Always put project skills in `<project_root>/.claude/skills/<skill-name>/SKILL.md`.
