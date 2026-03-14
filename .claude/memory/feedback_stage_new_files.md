---
name: Always stage new/untracked files when committing
description: When committing, check for new files created during the session (not just modified ones) and include them in the staging
type: feedback
---

When preparing commits, always check for new/untracked files that were created as part of the changes — not just modified files shown in `git diff`. In bare dotfiles repos, new files won't appear in `git diff` since they're untracked and ignored by the `*` gitignore pattern.

**Why:** User had to correct me when I staged only modified files but forgot the new `lib/dotfiles/*.sh` files that the refactored tasks depended on.

**How to apply:** Before committing, run `git status` and cross-reference with the work done to ensure all new files are included. Pay special attention to extracted/shared files.
