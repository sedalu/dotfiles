# Tasks

mise tasks are every repo's automation interface.
The git hooks, CI, and any deploy all enter through the same names,
so what a check does is decided once and not restated per caller.

- User-facing tasks carry a description; internal subtasks set `hide = true`.
- A task taking arguments declares them in a usage spec,
  and reads them as `$usage_<name>` —
  `#USAGE` header lines in a file task,
  the `usage` field in a TOML task.
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

`#MISE` carries TOML task properties,
`#USAGE` the argument spec.
Both need the prefix on every line,
so an array or a nested block spans lines with it repeated.

A parent delegates rather than repeating its children:

```toml
[tasks.check]
depends = ["check:staged"]
```

[examples/mise-task-check-all](examples/mise-task-check-all) is a working task file.

## Specs are linted

`usage lint <task-file>` reads a file task directly,
shebang and `#USAGE` header and all.
It catches what still parses:
a flag declared twice,
a required argument after an optional one,
a variadic argument that is not last,
an example its own spec cannot parse.
Run it with `--warnings-as-errors`,
and with `--sorted` to hold declaration order,
which is a convention rather than a correctness rule.

It takes one file per invocation,
and reads a task carrying no spec as raw KDL,
rather than skipping it,
so the step that runs it loops and skips the tasks that declare none.

## Sharing a spec between tasks

Flags repeated across tasks are declared once in a `flagset`,
and pulled in with `use`,
which expands in place at parse time:

```kdl
flagset "output" {
  flag "-v --verbose" help="Print more"
  flag "--json" help="Machine-readable output"
}
```

```bash
#USAGE use "output"
#USAGE flag "--target <triple>" help="What to build for"
```

A `flagset` is top-level,
and may be declared only once across every file that reaches the spec.
Reach for one when a flag is genuinely repeated;
a set with one consumer is a level of indirection buying nothing.

An `include` pulls a spec from another file,
and expands `$VAR` in the path —
but only when the caller supplies the environment.
mise does;
`usage lint` passes none, and has no flag to supply one,
so it opens a directory named `$MISE_CONFIG_ROOT` and fails.
Keep an include path relative,
which resolves against the including file and works under both.

## Spellings to avoid

| Do not write | Write instead |
| ------------ | ------------- |
| `USAGE_*` environment variables | `USAGECLI_*` — mise strips anything whose first six characters are `usage_`, case-insensitively |
| `about_long`, `help_long`, `before_help_long`, `after_help_long` | `long_about`, `long_help`, `before_long_help`, `after_long_help` |
| `restart_token` | `clause`, which keeps every instance instead of only the last |
| `data_type=` on a config `prop` | `type=` |

Declaring `subcommand_required` is no longer decorative —
it is enforced,
so a command that carried it for documentation now rejects bare invocation.
Write `--flag=value` wherever a value can look like a flag:
a value-taking flag followed by another flag-like token is an error,
rather than a silent binding.
