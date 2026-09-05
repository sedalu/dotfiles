# Design

System architecture and design rationale for the dotfiles repo.

## 1. Bare Git Repo Pattern

The repo uses git's `--separate-git-dir` feature:
the **worktree** lives at `$DOTFILES_DIR` (typically `~/.config`)
and the **git directory** lives at `$DOTFILES_GIT` (typically `~/.local/share/dotfiles.git`).

A `.git` *file* (not directory) at `$DOTFILES_DIR/.git` contains:

```text
gitdir: /Users/<user>/.local/share/dotfiles.git
```

This means plain `git` commands work from the worktree without `--git-dir`/`--work-tree` flags.

The `.gitignore` is `*` (ignore everything).
Files are added explicitly with `git add -f`.
The config `advice.addIgnoredFile = false` suppresses the resulting warnings.

**Why this approach:**

- No symlink farm — configs live in-place at their XDG paths
- Apps find real files where they expect them
- Standard git workflow (`status`, `diff`, `log`) works normally
- Selective tracking via explicit `git add -f`

## 2. Environment Variables

### XDG Base Directories

Set unconditionally in `shell/env.sh` — always `$HOME/.config`, etc.

| Variable           | Value                |
| ------------------ | -------------------- |
| `XDG_CONFIG_HOME`  | `$HOME/.config`      |
| `XDG_CACHE_HOME`   | `$HOME/.cache`       |
| `XDG_DATA_HOME`    | `$HOME/.local/share` |
| `XDG_STATE_HOME`   | `$HOME/.local/state` |

### DOTFILES_* Variables

Set conditionally in `shell/env.sh` using `${VAR:-default}`,
so values from `~/.dotfiles` take precedence.

| Variable           | Default                                          | Purpose                |
| ------------------ | ------------------------------------------------ | ---------------------- |
| `DOTFILES_DIR`     | `$XDG_CONFIG_HOME`                               | Worktree location      |
| `DOTFILES_GIT`     | `$XDG_DATA_HOME/dotfiles.git`                    | Git directory location |
| `DOTFILES_MACHINE` | Normalized hostname (see §5)                     | Machine identifier     |
| `DOTFILES_OS`      | `uname -s` lowercased                            | OS identifier          |
| `DOTFILES_SHELL`   | `basename $SHELL`                                | Default shell name     |

### Override Mechanism

`~/.dotfiles` is sourced at the top of `env.sh` (and at the top of `.bash_profile` / `.zshenv`).
The layering is:

1. `~/.dotfiles` — user overrides (optional file)
2. XDG vars — set unconditionally (not overridable)
3. `DOTFILES_*` vars — conditional (`${VAR:-default}`), reference XDG values

Example: setting `DOTFILES_DIR=/other/path` in `~/.dotfiles` works
because the `${DOTFILES_DIR:-$XDG_CONFIG_HOME}` expression sees it's already set and skips the default.

## 3. Shell Load Order

The shell config is split into two shared files, each with optional OS and machine layers:

- **`shell/env.sh`** — environment variables only
  (sourced by both `.zshenv` and `bash_env`)
- **`shell/interactive.sh`** — aliases, functions, pager/fzf config
  (sourced by both `.zshrc` and `.bashrc`)

Each file sources optional layers at the end (Global → OS → Machine):

1. `shell/{env,interactive}.sh` — base (always loaded)
2. `shell/{env,interactive}.${DOTFILES_OS}.sh` — OS-specific (if exists)
3. `shell/{env,interactive}.${DOTFILES_MACHINE}.sh` — machine-specific (if exists)

### Bash Chain

```text
.bash_profile
├── source ~/.dotfiles          (if exists)
├── source bash_env
│   └── source env.sh           (XDG, PATH, DOTFILES_*)
│       ├── source env.${OS}.sh        (if exists)
│       └── source env.${MACHINE}.sh   (if exists)
├── mkdir state/cache dirs
├── export BASH_ENV=bash_env    (non-interactive inheritance)
└── source .bashrc
    ├── [guard: exit if non-interactive]
    ├── [fallback: re-source env if HOMEBREW_PREFIX unset]
    ├── mise activate bash
    ├── _cached_source: fnox, fzf, starship, zoxide
    ├── history, completions, options, keybindings
    └── source interactive.sh
        ├── source interactive.${OS}.sh        (if exists)
        └── source interactive.${MACHINE}.sh   (if exists)
```

### Zsh Chain

```text
.zshenv
├── source ~/.dotfiles          (if exists)
├── source env.sh               (XDG, PATH, DOTFILES_*)
│   ├── source env.${OS}.sh        (if exists)
│   └── source env.${MACHINE}.sh   (if exists)
├── export ZDOTDIR=shell/zsh
├── mkdir state/cache dirs
└── export HISTFILE

.zshrc  (loaded later by zsh via ZDOTDIR)
├── mise activate zsh
├── _cached_source: fnox, fzf, starship
├── history, completions, plugins
├── _cached_source: zoxide
├── options, keybindings
└── source interactive.sh
    ├── source interactive.${OS}.sh        (if exists)
    └── source interactive.${MACHINE}.sh   (if exists)
```

### Key Mechanisms

**`BASH_ENV` trick:** `.bash_profile` exports `BASH_ENV` pointing to `bash_env`,
so non-interactive bash processes (cron, `env -i bash -c '...'`) inherit the full environment.

**`.bashrc` fallback:** Re-sources env if `HOMEBREW_PREFIX` is unset —
covers the edge case of a non-login bash shell in a clean environment (containers, `env -i bash`).

**`_cached_source`:** Regenerates activation scripts only when the binary is newer than the cached output.
Caches live at `$XDG_CACHE_HOME/{bash,zsh}/init/`.
Avoids subprocess overhead on every shell start.

## 4. OS-Specific Variations

`DOTFILES_OS` is derived from `uname -s` lowercased (`darwin`, `linux`).

| Concern              | macOS                                               | Linux                                       |
| -------------------- | --------------------------------------------------- | ------------------------------------------- |
| Homebrew prefix      | `/opt/homebrew` (Apple Silicon)                     | `/home/linuxbrew/.linuxbrew`                |
| Hostname retrieval   | `scutil --get LocalHostName`                        | `hostname`                                  |
| Machine name setting | `scutil --set` (3 names: Computer, Local, Hostname) | `hostnamectl set-hostname`                  |
| App installation     | `mise/hooks/install-app` (DMG → `~/Applications`)   | N/A                                         |
| Font installation    | `mise/hooks/install-fonts` (→ `~/Library/Fonts`)    | N/A                                         |
| ACL handling         | Strips deny-delete ACLs before replacing dirs       | N/A                                         |
| App Store            | `"mas:<adam-id>"` entries in `[bootstrap.packages]` | Skipped (manager unavailable)               |
| System packages      | `config.macos.toml` (auto-loaded) adds casks and App Store apps | `config.linux.toml` (none yet)  |

Homebrew paths are hardcoded in `env.sh` to avoid a `brew shellenv` subprocess on every shell start.

OS-specific shell layers (`shell/env.${DOTFILES_OS}.sh`, `shell/interactive.${DOTFILES_OS}.sh`)
are sourced at the end of their base files when present.
See §3 for the full load order.

## 5. Machine-Specific Variations

`DOTFILES_MACHINE` is derived from the normalized hostname or overridden via `~/.dotfiles`.

### Hostname Normalization

Defined in `lib/dotfiles/hostname.sh:normalize_hostname`:

1. Lowercase
2. Non-alphanumeric characters → hyphens
3. Collapse consecutive hyphens
4. Strip leading/trailing hyphens

Example: `My-MacBook Pro (2)` → `my-macbook-pro-2`

### Sidecar Pattern

Machine-specific config files are loaded alongside base config when a sidecar file matching the machine name exists:

| Base file                  | Sidecar pattern                            | Example                        |
| -------------------------- | ------------------------------------------ | ------------------------------ |
| `shell/env.sh`             | `shell/env.${MACHINE}.sh`                  | `env.caladan.sh`               |
| `shell/interactive.sh`     | `shell/interactive.${MACHINE}.sh`          | `interactive.caladan.sh`       |
| `mise/config.toml`         | `mise/config.${MACHINE}.toml`              | `config.caladan.toml`          |

The `mise/config.${MACHINE}.toml` layer is loaded by mise itself, not a shell `source`:
`mise/miserc.toml` sets `env = ["{{ env.DOTFILES_MACHINE }}"]` so mise loads `config.<machine>.toml`,
and `auto_env = true` additionally loads the per-OS `config.${DOTFILES_OS}.toml` (e.g. `config.macos.toml`).
The `[bootstrap.packages]`, `[dotfiles]`, and `[bootstrap.macos.defaults]` tables all union across whichever files load —
the native equivalent of the old `Brewfile.${MACHINE}`, `symlinks.${MACHINE}.sh`, and `settings.${MACHINE}.sh` sidecars.

Example: `config.caladan.toml` adds `~/Downloads` → iCloud Drive Downloads (and the Claude memory symlink) to `[dotfiles]`,
the Obsidian and Steam GUI apps to `[tools]` (installed from their DMGs via the `install-app` hook),
and caladan's scalar preferences (24-hour clock, menu-bar clock options, …) to `[bootstrap.macos.defaults]`.

## 6. Shell-Specific Variations

`DOTFILES_SHELL` is derived from `basename $SHELL` (`bash`, `zsh`).

### Separate Directories

| Shell | Config dir     | Cache dir                   | State dir                  |
| ----- | -------------- | --------------------------- | -------------------------- |
| Bash  | `shell/bash/`  | `$XDG_CACHE_HOME/bash/`    | `$XDG_STATE_HOME/bash/`   |
| Zsh   | `shell/zsh/`   | `$XDG_CACHE_HOME/zsh/`     | `$XDG_STATE_HOME/zsh/`    |

### Per-Shell Directories

Created by `lib/dotfiles/dirs.sh` and verified by `doctor:dirs`:

- `$XDG_DATA_HOME/bash/completions` — bash completion scripts
- `$XDG_STATE_HOME/bash` — bash history
- `$XDG_STATE_HOME/zsh` — zsh history
- `$XDG_CACHE_HOME/zsh/init` — cached activation scripts
- `$XDG_DATA_HOME/zsh/site-functions` — zsh site functions

### Activation Caches

`_cached_source` writes per-shell extensions:
`*.bash` in `$XDG_CACHE_HOME/bash/init/`, `*.zsh` in `$XDG_CACHE_HOME/zsh/init/`.

## 7. Library-Driven Configuration

The `lib/dotfiles/` directory contains shared definitions sourced by multiple tasks.
This ensures install tasks create exactly what doctor tasks verify — same definitions, different operations.

| Library file        | Defines                                     | Used by                                  |
| ------------------- | ------------------------------------------- | ---------------------------------------- |
| `dirs.sh`           | XDG directories to create/verify            | install:dirs, doctor:dirs                |
| `hostname.sh`       | `get_hostname`, `normalize_hostname`        | machine, doctor:machine                  |
| `zsh-plugins.sh`    | Plugin `name:url` pairs, `ZSH_PLUGINS_DIR` | install:zsh-plugins, doctor:zsh-plugins  |

Go's environment file, formerly defined here via `go.sh` and written by `go env -w`,
is now a declarative `[dotfiles]` template (§8) —
so `go` reads it natively in every context, not just mise-activated shells.

macOS configuration is split by what mise can express:

- **Scalar preferences** (`defaults write` values) are declared in `[bootstrap.macos.defaults]`
  (`mise/config.toml` + per-machine `config.${MACHINE}.toml`)
  and applied/verified by mise itself — `mise bootstrap macos-defaults apply` and `status --missing`.
- **Reset-catalog** — keys kept at their macOS default via `defaults delete`, plus the `killall_targets` restart map —
  stays in `macos/settings.sh`, because mise can express neither an absent key nor an app restart.
  It is synced from macos-defaults.com by `catalog:macos`.
- **Manual-only settings** with no `defaults` equivalent (Tips, Mail, Spotlight categories)
  are documented in `macos/manual.md`.

| Config file                         | Defines                                                  | Used by                                     |
| ----------------------------------- | -------------------------------------------------------- | ------------------------------------------- |
| `[bootstrap.macos.defaults]`        | Scalar `defaults write` preferences (base + per-machine) | install:macos, doctor:macos                 |
| `macos/settings.sh`                 | `defaults delete` reset-catalog + `killall_targets` map  | install:macos, doctor:macos, catalog:macos  |
| `lib/dotfiles/macos.sh`             | Reset-catalog parsing helpers                            | install:macos, doctor:macos, catalog:macos  |
| `[bootstrap.user].login_shell`      | Login shell (Homebrew zsh), per macOS machine            | install:login-shell, doctor:login-shell     |

`install:macos` applies the preferences via mise, sources the reset-catalog for the deletes,
and restarts only the apps whose domains actually changed —
write-domains from mise `status` (taken before apply), delete-domains from a before/after snapshot.
`doctor:macos` gates on `status --missing`, then checks each catalog key is absent.
Per-machine reset-catalog deletes are still supported via an optional `macos/settings.${MACHINE}.sh` sidecar (none currently).
Symlinks are likewise declared in `[dotfiles]` (see §8).

The **login shell** is a separate `[bootstrap.user]` concern, declared in `config.macos.toml`
(`login_shell = "/opt/homebrew/bin/zsh"` — the Homebrew zsh installed via `[bootstrap.packages]`, in place of the system `/bin/zsh`).
`mise bootstrap user apply` converges it:
it registers the shell in `/etc/shells` (a one-time `sudo` append) then `chsh`'s the account.
`install:login-shell` wraps `apply`; `doctor:login-shell` gates on `status --missing`.
Both skip when no `[bootstrap.user]` entry loads (non-macOS), so the path stays macOS-only.

## 8. Symlink System

Symlinks are declared in mise's `[dotfiles]` tables and applied by `mise dotfiles apply` (an experimental mise feature).
The base set lives in `mise/config.toml`;
per-machine entries in `config.${MACHINE}.toml` union with it (see §5).

### Declared Symlinks

Base (`mise/config.toml`), `mode = "symlink"`:

| Link                    | Source                                   |
| ----------------------- | ---------------------------------------- |
| `~/.claude`             | `~/.config/claude`                       |
| `~/.bash_profile`       | `~/.config/shell/bash/.bash_profile`     |
| `~/.bashrc`             | `~/.config/shell/bash/.bashrc`           |
| `~/.zshenv`             | `~/.config/shell/zsh/.zshenv`            |
| `~/.ssh/config`         | `~/.config/ssh/config`                   |

One base entry uses `mode = "template"` instead:
`~/.config/go/env` is rendered from `~/.config/go/env.tmpl`,
substituting XDG paths into Go's `GOPATH`/`GOMODCACHE`/`GOCACHE` env file.
A template, not a symlink, so a stray `go env -w` can't write back into the repo.

Per-machine (`config.caladan.toml`): the Claude project-memory symlink
and `~/Downloads` → iCloud Drive Downloads
(a non-repo source — `[dotfiles]` symlink mode accepts any existing path).

### Apply & Conflict Resolution

`.config/mise/tasks/install/symlinks` drives the apply:

1. **Backup pre-flight.** `mise dotfiles apply --force` overwrites conflicting targets but keeps no backup,
   and plain `rm` can't remove a macOS deny-delete directory (e.g. a pristine `~/Downloads`).
   For every declared target that exists as a real, non-symlink file/dir,
   the task strips any deny-delete ACL and moves it to `.bak`, preserving the user's data.
   Wrong symlinks and missing targets need no pre-flight.
2. **Apply.** `mise dotfiles apply --force --yes` creates/repairs every symlink.
   Already-correct entries are no-ops.

`doctor:symlinks` gates on `mise dotfiles status --missing`,
which exits non-zero on any drift (missing, source missing, or differs).

## 9. Mise Task Orchestration

All automation runs through `mise run` with tasks in `.config/mise/tasks/`.

These live in a **project-local** mise scope, not the global config dir.
The worktree root is `$DOTFILES_DIR` (`$XDG_CONFIG_HOME`), which is also mise's *global* config dir (`mise/config.toml`),
so tasks placed under `mise/tasks/` are visible from every directory on the machine.
Moving the dotfiles tasks to `.config/mise/tasks/` — one of mise's default file-task dirs, discovered by walking up from the cwd —
scopes them to the `$DOTFILES_DIR` subtree without leaking into the global task namespace.
mise won't load a non-global config until it's trusted,
so `shell/env.sh` exports `MISE_TRUSTED_CONFIG_PATHS="$DOTFILES_DIR/.config/mise"`;
this can't live in the global `config.toml`, since `trusted_config_paths` there is parsed before variables expand.
The `worktree:*` tasks deliberately stay global under `mise/tasks/` — they operate on any repo, not just this one.

The same collision reaches the *config* files, and there it is not benign.
`mise/config.toml` is both this machine's global mise config and a filename mise looks for in the cwd,
and the local list is later-wins with every `mise/*` entry ranked above every `.config/mise/*` one.
Inside the worktree the workstation toolchain therefore outranked the project config,
so the pipeline's pins resolved to the workstation's `latest` and only CI ran the versions we pinned.
`.config/miserc.toml` — an early-init file mise reads by walking up from the cwd — drops the three `mise/*`
entries from `override_config_filenames`, which leaves that file loading as the *global* config,
platform and machine layers intact, while the project pins win at project scope.
`doctor:pins` asserts exactly that, so a regression fails a health check instead of going unnoticed.
One residue: the platform layer (`mise/config.macos.toml`) is matched by mise's environment patterns,
which the setting does not cover, so it still loads locally.
It carries only `mas` and `cmux`, and keeping the pipeline's tools out of it keeps that harmless.

### Install Dependencies

```text
install
├── dirs             (parallel)
├── mise             (parallel)
│   └── system-packages  (mise bootstrap packages install)
├── macos            (parallel, darwin only)
├── login-shell      (parallel, macOS only via config)
├── symlinks         (parallel)
├── zsh-plugins      (parallel)
└── ssh              (depends: symlinks)
```

### Update Dependencies

```text
update
├── mise             (also runs `mise bootstrap packages upgrade`)
├── macos            (parallel, darwin only)
└── zsh-plugins      (parallel)
```

### Doctor Dependencies

```text
doctor
├── tools
├── mise             (depends: tools; also checks `mise bootstrap packages status --missing`)
├── repo             (depends: tools)
│   └── symlinks     (depends: repo)
├── dirs
│   ├── completions  (depends: dirs)
│   └── zsh-plugins  (depends: dirs)
├── macos            (parallel, darwin only)
├── login-shell      (parallel, macOS only via config)
├── ssh              (parallel)
├── machine          (parallel)
└── mas              (parallel, darwin only)
```

### Bootstrap

Full fresh-machine sequence (`.config/mise/tasks/bootstrap`):

1. Load `~/.dotfiles` overrides
2. Clone repo with `--separate-git-dir`
3. Write `.git` pointer file
4. Set `advice.addIgnoredFile = false`
5. Source `env.sh` directly from checkout
6. Run `machine` (interactive hostname setup)
7. Install mise if missing
8. Run `install`
9. Run `doctor` to verify

## 10. Linting, Formatting & Secret Scanning (hk)

[hk](https://hk.jdx.dev) drives all code quality.
The pipeline is declared in `.config/hk.pkl` (pkl, amending hk's `Config.pkl`),
with the per-tool sidecars beside it.
Every tool — `hk` itself plus `shellcheck`, `shfmt`, `tombi`, `rumdl`, `ryl`, `yamlfmt`, `typos`, `jq`, and `gitleaks` —
is pinned in `.config/mise/config.toml` with a lockfile beside it,
which is the project scope: the workstation toolchain this repo *ships* lives in `mise/config.toml`
and is a different thing entirely.

### Reaching the Sidecars

No step passes its config as a flag.
Each sidecar reaches its tool by the highest rung it supports on the ladder in
[`repo-layout.md`](dev-standards/repo-layout.md#where-a-config-file-goes):

| Sidecar                                    | Rung | How the tool finds it                                                  |
| ------------------------------------------ | ---- | ---------------------------------------------------------------------- |
| `tombi.toml`, `rumdl.toml`, `ryl.toml`     | 1    | native search — each already looks under `.config/`                    |
| `shellcheckrc`                             | 2    | `SHELLCHECK_OPTS` in `.config/mise/config.toml`                        |
| `yamlfmt.yaml`, `typos.toml`               | 3    | a wrapper in `.config/mise/bin/`, put ahead of the tool on `PATH`      |

The flags this replaced were not merely verbose, they were partial.
An hk builtin carries several commands per step — `check`, `check_diff`, `check_list_files`, `fix` —
and a flag added to one leaves the rest reading the tool's defaults:
the shellcheck step flagged `check` and left the builtin's `check_diff`,
so the path that runs under `fix` and `pre-commit` saw no `external-sources` at all.
Moving the config off the call site makes every command of every step read the same settings by construction,
and makes an interactive run in a terminal read them too.

`_.path` and `PROJECT_ROOT` in `.config/mise/config.toml` are what put the wrappers in front:
mise places `_.path` ahead of the tool install directories,
and each wrapper resolves its real binary with `mise which`,
which reads the toolset rather than `PATH` and so cannot find the wrapper again.
Because this repo's mise scope is the whole `$DOTFILES_DIR` worktree,
that shadowing is in effect for any run anywhere under it, not just for hk —
which is the intent, since these are the repo's own linters.

A config that is not found does not fail; the tool silently uses its defaults,
so `doctor:linter-configs` guards all five the way `doctor:pins` guards the pins.
Each probe asserts a rule this repo *changed* —
a long Markdown line passing (MD013 off), `Zeon` accepted, a blank line surviving yamlfmt,
an unquoted YAML string rejected (ryl enables no rules by default),
SC1091 staying quiet on a `source=` directive.
The probes match the exit code exactly rather than merely non-zero,
because a tool that cannot run at all must not read as one reporting the violation it was asked to find:
ryl without a config exits 2, and its rule violation exits 1.
Each of the five is confirmed to go red — with the sidecar moved aside,
the wrapper removed, or `SHELLCHECK_OPTS` deleted — and green again once restored.

### Step Classes

`hk.pkl` groups steps into three classes by what each is allowed to touch:

| Class            | Steps                                                                                        | Scope         | Hook role            |
| ---------------- | -------------------------------------------------------------------------------------------- | ------------- | -------------------- |
| Formatters       | newlines, mixed_line_ending, trailing_whitespace, shfmt, tombi_format, rumdl, jq, yamlfmt, ryl, typos | owned files   | run `fix`, never stage |
| Linters          | shellcheck, tombi                                                                            | owned files   | check only           |
| Guards + secrets | merge-conflict / large-file / case / shebang / symlink / private-key checks, gitleaks        | **all files** | check only           |

### Owned-Files Scope

Formatters and linters carry an `exclude` list (`notOurs`):
files written by another app or generated by a task —
`gh/hosts.yml`, `gh/config.yml`, `claude/settings.json`, Claude auto-memory, `obsidian/`, `cmux/`, `docs/TASKS.md`.
Excluding them keeps the pipeline from fighting the owning tool or churning generated output.
Because our shell scripts include many extensionless files (`bin/`, mise tasks/hooks),
the shell steps select through a single `match_any` clause carrying an explicit glob
(`**/*.sh`, `**/*.bash`, `bin/**`, `.config/mise/tasks/**`, `mise/tasks/**`, `mise/hooks/**`, `shell/bash/**`)
rather than the builtin `**/*.sh`.
zsh is deliberately absent — shfmt/shellcheck don't support it.
That single clause matters: the builtins otherwise add a detected-type selector,
which would pull zsh into the tools that cannot parse it.

YAML is split between two tools.
`ryl` owns the rules and `yamlfmt` owns the layout.
Each rule in `ryl.toml` that overlaps a layout decision is set to match what yamlfmt emits,
so the two never fight.
yamlfmt's `-lint` is not a second linter but its own format-drift check,
so the builtin's `check_diff` is left in place — without it `check` would see no YAML at all,
and drift would surface only when `fix` rewrote the file.
Both halves read `yamlfmt.yaml` through the wrapper,
since a check reading different settings than the fix is worse than no check.

### Secrets See Everything

The guards and the secret scanner deliberately skip the `exclude` list —
a leaked credential must be caught wherever it lands.
`gitleaks` runs in **`git` mode** (`gitleaks git`, reading blobs from history) rather than the builtin `dir` mode.
`gitleaks dir` walks the filesystem:
it ignores `.gitignore` and, given many path args, falls back to scanning `.`,
which would drag in the multi-GB gitignored trees under the worktree (colima VM state, Claude runtime data).
`git` mode is structurally blind to gitignored/untracked/symlinked files while scanning every committed line —
and is faster (~100 ms over full history).

### shellcheck Directives at the Call Site

`shellcheckrc` carries a single setting — `external-sources=true` —
because that is the one directive shellcheck rejects inside a file (SC1144),
and it is required so `# shellcheck source=` directives resolve across files.
Everything else is a *local* directive at the point it applies, keeping each check live everywhere else:

| Finding                           | Fix                                                                                                              |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| SC1090/SC1091 (sourced path)      | `# shellcheck source=SCRIPTDIR/…` (in-repo — doubles as a cross-file analysis hint) or `=/dev/null` (dynamic/external) before each `source` |
| SC2148 (no shebang)               | `# shellcheck shell=bash` atop each shebang-less sourced file (declares the dialect rather than disabling)       |
| SC2154 / SC2034 / SC2016 / SC2329 | targeted `# shellcheck disable=` with a documented reason                                                        |

`source=` paths resolve against the *caller's* CWD (the repo root under hk),
so the robust form is the `SCRIPTDIR` token, which shellcheck expands to each script's own directory.

### Git Hooks

`git/config` registers hk for each git event via `[hook]` entries that run `mise x -- hk run <event> --from-hook`,
gated on `${HK:-1}` (export `HK=0` to bypass).
`pre-commit` runs guards + formatters + linters, with `stage = false` and `fail_on_fix = true`:
a fix lands in the working tree and *blocks* the commit rather than being staged into it,
so nothing reaches a commit that was not read and staged by hand;
`commit-msg` enforces conventional commits;
`pre-push` runs the secret scan.

Outside the hooks the pipeline is entered through mise tasks, never `hk` directly:
`check` and `fix` take the staged set, `check:all` and `fix:all` the whole tree, and `check:pr`/`fix:pr` the
diff against the default branch.
CI runs `check:all` — the same task, so what a check does is decided once rather than restated per caller.
