# Tasks

mise tasks are every repo's automation interface.
The git hooks, CI, and any deploy all enter through the same names,
so what a check does is decided once and not restated per caller.

- User-facing tasks carry a description; internal subtasks set `hide = true`.
- A task taking arguments declares them in its `usage` field and reads them as `$usage_<name>`.
- Decompose a multi-scope task into one task per scope
  and let the bare name delegate via `depends`.
  Compose through `depends`, never by duplicating commands.
- A parent task does not collapse into its only child.
  It stays the entry point, so gaining a second child never renames it.
- A second name for a task is its `alias` field, never a second task.
  A task that only shells out to another task duplicates it; use `depends`.
- Layering runs one direction only:
  mise tasks wrap hk, and hk steps invoke tools directly.
  An hk step never shells out to a mise task.

## Entry points

The names are fixed, so the same command means the same thing in every repo.
A repo exposes the ones that apply to it — a library has no `run` —
but it never invents a different name for one that does.

Quality:

| Task                          | Does                                    |
| ----------------------------- | --------------------------------------- |
| `check:staged` / `fix:staged` | The staged set                          |
| `check:all` / `fix:all`       | The whole tree — what CI runs           |
| `check:pr` / `fix:pr`         | The diff against the default branch     |
| `check` / `fix`               | Delegates to the default scope          |
| `pre-commit` / `pre-push`     | What the corresponding git hook invokes |

Lifecycle:

| Task                                      | Does                                     |
| ----------------------------------------- | ---------------------------------------- |
| `build`                                   | Produces every deployable artifact       |
| `run`                                     | Runs the thing locally                   |
| `test:unit` / `test:feature` / `test:e2e` | One tier each, defined in [testing.md](testing.md) |
| `test`                                    | Delegates to the default tier            |
| `generate`                                | Regenerates every generated file         |
| `clean`                                   | Removes build output and generated caches |

A repo with more than one binary scopes the verb rather than renaming it —
`build:api`, `run:worker` — and the bare name covers all of them.

Build artifacts go to a gitignored `bin/`,
never a bare toolchain build command that drops output in the current directory.

`generate` is the only way a generated file is produced.
The pipeline gates drift rather than regenerating —
a check that rewrites the tree to make itself pass is not a check.

A task file declares its interface in its header:

```bash
#!/usr/bin/env bash
#MISE description="Lint the staged set"
#USAGE flag "--fix" help="Apply fixes instead of reporting"
```

A parent delegates rather than repeating its children:

```toml
[tasks.check]
depends = ["check:staged"]
```

[examples/mise-task-check-all](examples/mise-task-check-all) is a working task file.
