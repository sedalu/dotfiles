# Dependency updates

Renovate proposes every version bump. Nothing is bumped by hand on a schedule.

Its config placement is fixed by the forge and lands on rule 4 of [repo-layout.md](repo-layout.md):
`renovate.json5` under `.forgejo/`.

**That path is not discovered on its own**, and whatever runs Renovate has to declare it.
Discovery walks a fixed list — `renovate.json{,c,5}`, `.github/renovate.json{,c,5}`,
`.gitlab/renovate.json{,c,5}`, `.renovaterc`, `.renovaterc.json{,c,5}`, `package.json` —
and `.forgejo/` is not in it on any platform.
`getConfigFileNames()` takes a platform argument that would add it,
but `detectConfigFile()` calls it without one,
so the platform-specific names reach config validation and never reach discovery.
Set `configFileNames` (`RENOVATE_CONFIG_FILE_NAMES`), which prepends to that list.
The declaration and the file move together or not at all.

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

## Two ways it reports success having done nothing

Both are silent, and both were met before Renovate ever opened a pull request here.

- **The config is at a path Renovate does not look in.**
  The repository finishes `disabled-no-config`.
  Under `onboarding: false` nothing is written anywhere —
  no issue, no pull request, no non-zero exit.
- **The clone fails.**
  The repository finishes `external-host-error` with `cloned: false`,
  and **Renovate still exits 0**, so the job reports green.

A run that did nothing and a run with nothing to do look identical from the outside.
Read `Repository finished` in the log and require `result: done` —
a green check is not evidence that anything was examined.

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
