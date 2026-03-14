---
name: Store project memories in .claude/memory/ not global projects path
description: Project memories should live in the repo's .claude/ directory, not ~/.claude/projects/
type: feedback
---

Store project-level memories in `$DOTFILES_DIR/.claude/memory/`, not in `~/.claude/projects/<path>/memory/`. The project's `.claude/` directory is the correct location for project-scoped persistence.

**Why:** User corrected me for writing memories to the global Claude projects path instead of the project's own `.claude/` directory.

**How to apply:** For this dotfiles repo, the memory path is `$DOTFILES_DIR/.claude/memory/`. Use `$DOTFILES_DIR` or relative paths when referring to this repo, not absolute paths.
