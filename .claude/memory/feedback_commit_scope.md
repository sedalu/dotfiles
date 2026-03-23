---
name: feedback_commit_scope
description: Only stage files related to the task when committing — don't include unrelated changes
type: feedback
---

Only include files directly related to the current task when staging a commit. Don't bundle in unrelated modified files just because they show up in git status.

**Why:** User flagged an unrelated `claude/settings.json` change being included in an obsidian integration commit.

**How to apply:** Before staging, review each file and confirm it's part of the task. When in doubt, leave it out.
