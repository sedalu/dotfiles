# Continuous integration

CI runs the same pipeline the git hooks run, through the same entry point.

A workflow step invokes a task from [tasks.md](tasks.md) — `mise run check:all` — and nothing else.
It never names a linter, a formatter, or a test runner directly.
A workflow that calls golangci-lint itself has forked the pipeline:
the two configurations drift, and the divergence shows up as a check
that passes locally and fails on the runner, or worse, the reverse.
Where CI needs something the local pipeline does not do, that is a new task, not a new step.

For the same reason the runner installs mise and nothing else.
Every tool arrives pinned, from the lockfile, exactly as it does on a workstation.
A runner that provisions a language toolchain through the forge's own setup action
is running a version no one pinned.

## Triggers and gating

- Every pull request runs `check:all`, and it is a required check.
- The default branch runs it again on push,
  because a merge can produce a tree neither parent had.
- Concurrency is keyed on the ref, and older in-flight runs are cancelled.
  This is the opposite of the deploy rule in [deployment.md](deployment.md):
  a superseded check run is wasted work, while a superseded deploy is a half-applied change.

## Runners

- **A run that is "running" with no job container on the host is wedged, not slow.**
  Restart the runner.
- **One shared runner is a shared failure.**
  A wedged runner blocks every repo, not just the one whose job wedged it.
- **A runner holds no long-lived credentials.**
  Each repo gets its own key — see [secrets.md](secrets.md).
