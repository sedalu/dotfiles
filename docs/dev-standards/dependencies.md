# Dependency updates

Renovate proposes every version bump. Nothing is bumped by hand on a schedule.

Its config placement is fixed by the forge and lands on rule 4 of [repo-layout.md](repo-layout.md):
`renovate.json5` under `.github/` on GitHub, `.forgejo/` on Forgejo.
The two are not interchangeable.
Renovate discards every `.<platform>/renovate.json*` candidate
whose platform is not the one it is running against,
so a repo on Forgejo never reads `.github/renovate.json5`
and a repo on GitHub never reads `.forgejo/renovate.json5`.

Do not set `managerFilePatterns` for the mise manager.
Its defaults already cover every layout these standards allow,
`.config/mise/config.toml` and `.config/mise.toml` included.
The option replaces the defaults rather than extending them,
so setting it means a config that moves later silently stops being seen.

## What a Renovate PR must do

- **Update the pin and the lockfile together.**
  A PR that moves one and not the other produces the state
  [tooling.md](tooling.md) warns about, where the declared version is not the resolved one.
- **Pass the same required checks as any other PR.**
  This is the entire safety argument for automating updates:
  the pipeline in [ci.md](ci.md) is what makes an unattended bump acceptable.
  It only holds if the forge enforces it.
  Renovate arms the platform's native "merge when checks succeed" as it opens the pull request,
  so a branch with no required context has nothing to wait for and merges on creation.
  Confirm the protection rule in [git.md](git.md) before enabling automerge anywhere.

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
