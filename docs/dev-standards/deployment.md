# Deployment

Applies when merging to the default branch deploys something.

Every deploy workflow declares both a dispatch trigger and a non-cancelling concurrency group:

```yaml
"on":
  push:
    branches: [main]
  workflow_dispatch:

concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: false
```

- **`cancel-in-progress: false`** — the forge cancels an in-flight run
  when a newer push lands on the same ref,
  so merging two pull requests in quick succession
  kills the first deploy before it has applied anything.
  Check runs cancel; deploys do not.
- **`workflow_dispatch`** — without it,
  re-deploying the current default branch is reachable only by pushing to a protected branch.
  Recovery from a failed or skipped deploy depends on it.

## Operating rules

- **Treat a cancelled run as "did not deploy".**
  It reports as neither success nor failure,
  so the default branch can sit undeployed with nothing to signal it.
- **CD deploys from its own checkout.**
  A copy of the repo checked out on a host for dispatch or cron does not advance when CD merges.
  Pull it after a merge, or the host keeps running the old scripts
  while the repo says they are fixed.

Runner health is in [ci.md](ci.md); it applies to deploy runs identically.
