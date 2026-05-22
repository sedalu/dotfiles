---
name: Always use git add -f in dotfiles repo
description: Dotfiles repo uses bare-repo pattern with global * gitignore — git add without -f will always error
type: feedback
---

Always use `git add -f` when staging files in this dotfiles repo.

**Why:** The repo uses the bare-repo dotfiles pattern with a `.gitignore` containing `*` (ignore everything). Files are selectively force-added. Plain `git add` will always fail with "The following paths are ignored by one of your .gitignore files". The `advice.addIgnoredFile = false` config only suppresses the hint text, not the error itself.

**How to apply:** Any time you commit in this repo, use `git add -f <file>` instead of `git add <file>`.
