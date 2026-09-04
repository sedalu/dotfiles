# Dependency updates

Renovate proposes every version bump. Nothing is bumped by hand on a schedule.

Its config placement is fixed by the forge and lands on rule 4 of [repo-layout.md](repo-layout.md):
`renovate.json5` under `.github/` or `.forgejo/`.
Set `managerFilePatterns` for the mise manager so it finds a config moved to `.config/`.

## What a Renovate PR must do

- **Update the pin and the lockfile together.**
  A PR that moves one and not the other produces the state
  [tooling.md](tooling.md) warns about, where the declared version is not the resolved one.
- **Pass the same required checks as any other PR.**
  This is the entire safety argument for automating updates:
  the pipeline in [ci.md](ci.md) is what makes an unattended bump acceptable.

## Grouping and merge policy

- Group by ecosystem, not by schedule.
  A mise tool bump and an application dependency bump are reviewed differently
  and do not belong in one PR.
- **May automerge:** patch and minor updates to development tooling —
  linters, formatters, and test dependencies — where CI covers the change.
- **Never automerges:** anything that reaches production, and every major version.
  A major bump gets a human reading its changelog.
- A pinned major that Renovate keeps proposing is a decision to record in the config,
  with the reason, not a PR to keep closing.

Never widen a version constraint to quiet an update PR.
[tooling.md](tooling.md) requires explicit versions;
a range is the pin being abandoned rather than moved.
