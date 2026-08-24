---
name: feedback-commit-renames-separately
description: "Commit a file move/rename on its own before changing its contents, so git records it as a rename"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 36186a78-3fba-4f60-b8a6-9882a81ddb8e
  modified: 2026-08-18T02:47:29.632Z
---

When a task involves both moving a file and editing it,
commit the move by itself first, then commit the content change.

**Why:** git detects a rename by content similarity.
A move plus a heavy edit in one commit shows up as a delete and an add,
which loses `git log --follow` and makes the history unreadable.
A standalone rename commit shows `0 insertions(+), 0 deletions(-)` and is unambiguous.

**How to apply:** use `git mv`, commit with only the rename staged,
verify with `git show --stat` that it reports zero line changes,
then make the edits as a second commit.
Applies to directory renames too.
See [[feedback-never-rewrite-commits]].
