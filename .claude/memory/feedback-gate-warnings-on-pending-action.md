---
name: feedback-gate-warnings-on-pending-action
description: Only print a heads-up about a side effect (e.g. a password prompt) when the action that triggers it will actually run this time
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b377a303-4c9c-4be6-ac4d-8311a4c88c9b
---

Before printing a warning/heads-up about a side effect a command might cause,
check whether that command will actually do anything this run — don't print it unconditionally.

**Why:** In `update:mas` (`.config/mise/tasks/update/mas`), `mas upgrade` can pop a macOS
password prompt with no warning of its own. My first fix echoed the heads-up unconditionally
right before `mas upgrade`. The user corrected this: check `mas outdated` first and only print
the heads-up when there are apps actually pending an update. This matches the repo's existing
"stays quiet when everything is already current" convention for update tasks
(see `update/mise`, `update/zsh-plugins`).

**How to apply:** When adding a warning before a side-effecting command, gate it on a preceding
check of whether the side effect will actually occur (e.g. `mas outdated`, a dry-run flag, a diff
of before/after state) rather than always printing it. Applies broadly to any task/script that
warns about prompts, restarts, or other noisy side effects.
