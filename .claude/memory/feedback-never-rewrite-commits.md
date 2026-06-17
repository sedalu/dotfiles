---
name: feedback-never-rewrite-commits
description: Never amend/rebase/reset/rewrite git commits unless explicitly told to
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 77ad1907-7fa9-41db-a934-a6ef8e309ef9
---

Never rewrite git history — no `git commit --amend`, rebase, reset, or force-push —
unless the user explicitly asks for it. For follow-up work, make a NEW commit on top.

**Why:** In ~/.config I committed, the commit got pushed, then I `--amend`ed it three
times across follow-up requests. That rewrote published history and left local
diverged from origin (ahead 1 / behind 1), which the user had to untangle. The user
was firm: do not rewrite commits unless explicitly told.

**How to apply:** Treat amend/rebase/reset/force-push as user-only decisions. When
new changes follow an earlier commit, add another commit. Only the user decides when
history gets rewritten. See [[dotfiles-commit-to-main]].
