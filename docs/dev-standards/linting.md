# Linting and formatting

hk owns every check.
Its pipeline lives in `.config/hk.pkl`, with each tool's sidecar config beside it.
mise wraps hk; hk never calls back into mise.

A step is a builtin with the parts this repo overrides, and nothing more:

```pkl
local rumdl = (Builtins.rumdl) {
  exclude = notOurs
  fix = "rumdl check --config .config/rumdl.toml --fix {{ files }}"
}
```

A builtin that offers a choice takes it in that same block,
beside the generic step properties,
rather than through a separate named variant:

```pkl
local gitleaks = (Builtins.gitleaks) { scan = "staged" }
```

The pipeline's meaning is in how those steps compose into hooks,
which a fragment cannot show — [examples/hk.pkl](examples/hk.pkl) is a working one.

Declaring steps at the top level is optional.
It creates `check`, `fix`, and `pre-commit` from one list,
which suits a pipeline where all three run the same steps.
Hooks that differ from each other — a `pre-push` that only scans for secrets,
a `pre-commit` that fixes where `check` reports — are declared as hooks instead.
No other hook name is ever created implicitly.

## Staging

Only `pre-commit` stages what it fixed.
Every other hook leaves its fixes in the working tree,
and a step's own `stage` globs filter what gets staged,
rather than enabling it.

Prefer that default to restoring the old one with `stage = true`.
A fix that stages itself puts bytes into a commit that nobody read,
which is the same objection that makes `stage = false` worth setting on `pre-commit` too:
the pipeline reports and repairs,
and a human decides what is committed.

## Tool assignments

One tool owns each concern.

| Concern      | Tool                 | Sidecar                |
| ------------ | -------------------- | ---------------------- |
| Markdown     | rumdl                | `.config/rumdl.toml`   |
| YAML lint    | ryl                  | `.config/ryl.toml`     |
| YAML format  | yamlfmt              | `.config/yamlfmt.yaml` |
| TOML         | tombi                | `.config/tombi.toml`   |
| Shell        | shellcheck + shfmt   | `.config/shellcheckrc` |
| JSON         | jq                   | —                      |
| JS/TS/GraphQL | biome               | `.config/biome.json`   |
| Spelling     | typos                | `.config/typos.toml`   |
| Secrets      | gitleaks             | —                      |
| Task specs   | usage lint           | —                      |
| pkl, mise    | hk builtins          | —                      |

Structural builtins (`check_merge_conflict`, `check_case_conflict`, `check_symlinks`,
`check_executables_have_shebangs`, `detect_private_key`, `trailing_whitespace`,
`mixed_line_ending`, `newlines`) run in every repo.

## Rules

- **One formatter owns each file type.**
  Narrow every glob to the types its tool owns.
  A formatter left on its default glob claims file types another tool owns,
  and the two rewrite each other's output forever.
- **Align formatter and linter where they disagree.**
  yamlfmt strips the `---` document start,
  so `ryl.toml` must set `document-start present = false`.
- **Allow-list the token `typos` *reports*, never the word you see in the file.**
  It splits an identifier before checking —
  a plural acronym becomes its uppercase run plus a trailing lowercase fragment,
  and only the uppercase run is reported.
  An entry keyed on the whole word never matches,
  and the correction comes back on the next run.

## Scope

Formatters and linters run only on files the repo owns.
Exclude app-managed files — credential stores, tool-written settings —
so the pipeline does not fight the owning app.

Generated files divide by who owns the generator.
Output from a generator this repo owns stays on the list of files to lint:
a formatter that wants to rewrite it is reporting a bug in the generator,
and the generator is what gets fixed — see [documentation.md](documentation.md).
Output from a vendor's generator is excluded alongside the app-managed files,
for the same reason:
the bytes belong to a program this repo does not control.

That list is declared once and applied to every owned step,
so a newly excluded path cannot be missed at one call site:

```pkl
local notOurs = List(
  "claude/settings.json",  // app-managed: Claude writes it
  "docs/TASKS.md"          // vendor-generated: `mise generate task-docs` emits it
)
local tombi = (Builtins.tombi) { exclude = notOurs }
```

Secret scanning is the exception: it scans everything.
Run gitleaks in `git` mode so it reads committed blobs,
which covers every committed line
and structurally ignores untracked or gitignored trees under the worktree.
