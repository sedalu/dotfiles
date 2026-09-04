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

The pipeline's meaning is in how those steps compose into hooks,
which a fragment cannot show — [examples/hk.pkl](examples/hk.pkl) is a working one.

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
Exclude app-managed and generated files —
credential stores, tool-written settings, generated catalogs —
so the pipeline does not fight the owning app or churn generated output.

That list is declared once and applied to every owned step,
so a newly excluded path cannot be missed at one call site:

```pkl
local notOurs = List("gh/hosts.yml", "docs/TASKS.md")
local taplo = (Builtins.taplo) { exclude = notOurs }
```

Secret scanning is the exception: it scans everything.
Run gitleaks in `git` mode so it reads committed blobs,
which covers every committed line
and structurally ignores untracked or gitignored trees under the worktree.
