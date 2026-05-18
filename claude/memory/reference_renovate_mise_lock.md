---
name: Renovate + mise lock file gap
description: When Renovate updates mise tool versions, it won't regenerate mise.lock — requires a CI step or manual follow-up
type: reference
---

When configuring Renovate to manage mise tool versions (`"mise": { "enabled": true }`), Renovate will bump version numbers in `.mise/config.toml` but will NOT run `mise lock` to regenerate the lock file.

**Why:** Renovate only edits config files; it has no awareness of mise's lock regeneration step.

**How to apply:** When setting up Renovate for a repo that uses `mise.lock`, add a CI step (or post-update hook) that runs `mise lock` and commits the result. Options:
- Add a Renovate `postUpgradeTasks` command to run `mise lock` after bumping
- Accept that lock file updates are a manual follow-up after Renovate PRs merge
