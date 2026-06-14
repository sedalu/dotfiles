# Design

System architecture and design rationale for the dotfiles repo.

## 1. Bare Git Repo Pattern

The repo uses git's `--separate-git-dir` feature: the **worktree** lives at `$DOTFILES_DIR` (typically `~/.config`) and the **git directory** lives at `$DOTFILES_GIT` (typically `~/.local/share/dotfiles.git`).

A `.git` *file* (not directory) at `$DOTFILES_DIR/.git` contains:

```
gitdir: /Users/<user>/.local/share/dotfiles.git
```

This means plain `git` commands work from the worktree without `--git-dir`/`--work-tree` flags.

The `.gitignore` is `*` (ignore everything). Files are added explicitly with `git add -f`. The config `advice.addIgnoredFile = false` suppresses the resulting warnings.

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

Set conditionally in `shell/env.sh` using `${VAR:-default}`, so values from `~/.dotfiles` take precedence.

| Variable           | Default                                          | Purpose                |
| ------------------ | ------------------------------------------------ | ---------------------- |
| `DOTFILES_DIR`     | `$XDG_CONFIG_HOME`                               | Worktree location      |
| `DOTFILES_GIT`     | `$XDG_DATA_HOME/dotfiles.git`                    | Git directory location |
| `DOTFILES_MACHINE` | Normalized hostname (see §5)                     | Machine identifier     |
| `DOTFILES_OS`      | `uname -s` lowercased                            | OS identifier          |
| `DOTFILES_SHELL`   | `basename $SHELL`                                | Default shell name     |

### Override Mechanism

`~/.dotfiles` is sourced at the top of `env.sh` (and at the top of `.bash_profile` / `.zshenv`). The layering is:

1. `~/.dotfiles` — user overrides (optional file)
2. XDG vars — set unconditionally (not overridable)
3. `DOTFILES_*` vars — conditional (`${VAR:-default}`), reference XDG values

Example: setting `DOTFILES_DIR=/other/path` in `~/.dotfiles` works because the `${DOTFILES_DIR:-$XDG_CONFIG_HOME}` expression sees it's already set and skips the default.

## 3. Shell Load Order

The shell config is split into two shared files, each with optional OS and machine layers:

- **`shell/env.sh`** — environment variables only (sourced by both `.zshenv` and `bash_env`)
- **`shell/interactive.sh`** — aliases, functions, pager/fzf config (sourced by both `.zshrc` and `.bashrc`)

Each file sources optional layers at the end (Global → OS → Machine):

1. `shell/{env,interactive}.sh` — base (always loaded)
2. `shell/{env,interactive}.${DOTFILES_OS}.sh` — OS-specific (if exists)
3. `shell/{env,interactive}.${DOTFILES_MACHINE}.sh` — machine-specific (if exists)

### Bash Chain

```
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

```
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

**`BASH_ENV` trick:** `.bash_profile` exports `BASH_ENV` pointing to `bash_env`, so non-interactive bash processes (cron, `env -i bash -c '...'`) inherit the full environment.

**`.bashrc` fallback:** Re-sources env if `HOMEBREW_PREFIX` is unset — covers the edge case of a non-login bash shell in a clean environment (containers, `env -i bash`).

**`_cached_source`:** Regenerates activation scripts only when the binary is newer than the cached output. Caches live at `$XDG_CACHE_HOME/{bash,zsh}/init/`. Avoids subprocess overhead on every shell start.

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
| App Store            | `mas` tasks run only when `DOTFILES_OS=darwin`      | Skipped                                     |
| System packages      | `config.macos.toml` adds the `mas` CLI to `[bootstrap.packages]` (auto-loaded) | `config.linux.toml` (none yet) |

Homebrew paths are hardcoded in `env.sh` to avoid a `brew shellenv` subprocess on every shell start.

OS-specific shell layers (`shell/env.${DOTFILES_OS}.sh`, `shell/interactive.${DOTFILES_OS}.sh`) are sourced at the end of their base files when present. See §3 for the full load order.

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
| `mas/apps`                 | `mas/apps.${MACHINE}`                      | `mas/apps.caladan`             |
| `homebrew/Brewfile`        | `homebrew/Brewfile.${MACHINE}`             | `Brewfile.caladan`             |
| `mise/config.toml`         | `mise/config.${MACHINE}.toml`              | `config.caladan.toml`          |

The `mise/config.${MACHINE}.toml` layer is loaded by mise itself, not a shell `source`: `mise/miserc.toml` sets `env = ["{{ env.DOTFILES_MACHINE }}"]` so mise loads `config.<machine>.toml`, and `auto_env = true` additionally loads the per-OS `config.${DOTFILES_OS}.toml` (e.g. `config.macos.toml`). The `[bootstrap.packages]`, `[dotfiles]`, and `[bootstrap.macos.defaults]` tables all union across whichever files load — the native equivalent of the old `Brewfile.${MACHINE}`, `symlinks.${MACHINE}.sh`, and `settings.${MACHINE}.sh` sidecars.

Example: `config.caladan.toml` adds `~/Downloads` → iCloud Drive Downloads (and the Claude memory symlink) to `[dotfiles]`, and caladan's scalar preferences (24-hour clock, menu-bar clock options, …) to `[bootstrap.macos.defaults]`.

## 6. Shell-Specific Variations

`DOTFILES_SHELL` is derived from `basename $SHELL` (`bash`, `zsh`).

### Separate Directories

| Shell | Config dir     | Cache dir                   | State dir                  |
| ----- | -------------- | --------------------------- | -------------------------- |
| Bash  | `shell/bash/`  | `$XDG_CACHE_HOME/bash/`    | `$XDG_STATE_HOME/bash/`   |
| Zsh   | `shell/zsh/`   | `$XDG_CACHE_HOME/zsh/`     | `$XDG_STATE_HOME/zsh/`    |

### Per-Shell Directories

Created by `lib/dotfiles/dirs.sh` and verified by `dotfiles:doctor:dirs`:

- `$XDG_DATA_HOME/bash/completions` — bash completion scripts
- `$XDG_STATE_HOME/bash` — bash history
- `$XDG_STATE_HOME/zsh` — zsh history
- `$XDG_CACHE_HOME/zsh/init` — cached activation scripts
- `$XDG_DATA_HOME/zsh/site-functions` — zsh site functions

### Activation Caches

`_cached_source` writes per-shell extensions: `*.bash` in `$XDG_CACHE_HOME/bash/init/`, `*.zsh` in `$XDG_CACHE_HOME/zsh/init/`.

## 7. Library-Driven Configuration

The `lib/dotfiles/` directory contains shared definitions sourced by multiple tasks. This ensures install tasks create exactly what doctor tasks verify — same definitions, different operations.

| Library file        | Defines                                     | Used by                                  |
| ------------------- | ------------------------------------------- | ---------------------------------------- |
| `dirs.sh`           | XDG directories to create/verify            | install:dirs, doctor:dirs                |
| `hostname.sh`       | `get_hostname`, `normalize_hostname`        | machine, install:mas, env.sh             |
| `zsh-plugins.sh`    | Plugin `name:url` pairs, `ZSH_PLUGINS_DIR` | install:zsh-plugins, doctor:zsh-plugins  |
| `go.sh`             | Go XDG-compliant paths                      | install:go, doctor:go                    |

macOS configuration is split by what mise can express:

- **Scalar preferences** (`defaults write` values) are declared in `[bootstrap.macos.defaults]` (`mise/config.toml` + per-machine `config.${MACHINE}.toml`) and applied/verified by mise itself — `mise bootstrap macos-defaults apply` and `status --missing`.
- **Reset-catalog** — keys kept at their macOS default via `defaults delete`, plus the `killall_targets` restart map — stays in `macos/settings.sh`, because mise can express neither an absent key nor an app restart. It is synced from macos-defaults.com by `dotfiles:catalog:macos`.
- **Manual-only settings** with no `defaults` equivalent (Tips, Mail, Spotlight categories) are documented in `macos/manual.md`.

| Config file                         | Defines                                                  | Used by                                     |
| ----------------------------------- | -------------------------------------------------------- | ------------------------------------------- |
| `[bootstrap.macos.defaults]`        | Scalar `defaults write` preferences (base + per-machine) | install:macos, doctor:macos                 |
| `macos/settings.sh`                 | `defaults delete` reset-catalog + `killall_targets` map  | install:macos, doctor:macos, catalog:macos  |
| `lib/dotfiles/macos.sh`             | Reset-catalog parsing helpers                            | install:macos, doctor:macos, catalog:macos  |

`install:macos` applies the preferences via mise, sources the reset-catalog for the deletes, and restarts only the apps whose domains actually changed — write-domains from mise `status` (taken before apply), delete-domains from a before/after snapshot. `doctor:macos` gates on `status --missing`, then checks each catalog key is absent. Per-machine reset-catalog deletes are still supported via an optional `macos/settings.${MACHINE}.sh` sidecar (none currently). Symlinks are likewise declared in `[dotfiles]` (see §8).

## 8. Symlink System

Symlinks are declared in mise's `[dotfiles]` tables and applied by `mise dotfiles apply` (an experimental mise feature). The base set lives in `mise/config.toml`; per-machine entries in `config.${MACHINE}.toml` union with it (see §5).

### Declared Symlinks

Base (`mise/config.toml`), all `mode = "symlink"`:

| Link                    | Source                                   |
| ----------------------- | ---------------------------------------- |
| `~/.claude`             | `~/.config/claude`                       |
| `~/.bash_profile`       | `~/.config/shell/bash/.bash_profile`     |
| `~/.bashrc`             | `~/.config/shell/bash/.bashrc`           |
| `~/.zshenv`             | `~/.config/shell/zsh/.zshenv`            |
| `~/.ssh/config`         | `~/.config/ssh/config`                   |

Per-machine (`config.caladan.toml`): the Claude project-memory symlink and `~/Downloads` → iCloud Drive Downloads (a non-repo source — `[dotfiles]` symlink mode accepts any existing path).

### Apply & Conflict Resolution

`mise/tasks/dotfiles/install/symlinks` drives the apply:

1. **Backup pre-flight.** `mise dotfiles apply --force` overwrites conflicting targets but keeps no backup, and plain `rm` can't remove a macOS deny-delete directory (e.g. a pristine `~/Downloads`). For every declared target that exists as a real, non-symlink file/dir, the task strips any deny-delete ACL and moves it to `.bak`, preserving the user's data. Wrong symlinks and missing targets need no pre-flight.
2. **Apply.** `mise dotfiles apply --force --yes` creates/repairs every symlink. Already-correct entries are no-ops.

`dotfiles:doctor:symlinks` gates on `mise dotfiles status --missing`, which exits non-zero on any drift (missing, source missing, or differs).

## 9. Mise Task Orchestration

All automation runs through `mise run` with tasks in `mise/tasks/dotfiles/`.

### Install Dependencies

```
dotfiles:install
├── brew             (parallel)
├── dirs             (parallel)
├── mise             (parallel)
│   └── system-packages  (mise bootstrap packages install)
├── go               (parallel)
├── macos            (parallel, darwin only)
├── symlinks         (parallel)
├── zsh-plugins      (parallel)
├── mas              (depends: mise:system-packages; darwin only)
└── ssh              (depends: symlinks)
```

### Update Dependencies

```
dotfiles:update
├── brew
├── mise             (depends: brew; also runs `mise bootstrap packages upgrade`)
├── macos            (parallel, darwin only)
├── zsh-plugins      (parallel)
└── mas              (parallel, darwin only)
```

### Doctor Dependencies

```
dotfiles:doctor
├── tools
├── brew             (depends: tools)
├── mise             (depends: tools; also checks `mise bootstrap packages status --missing`)
├── repo             (depends: tools)
│   └── symlinks     (depends: repo)
├── dirs
│   ├── completions  (depends: dirs)
│   └── zsh-plugins  (depends: dirs)
├── go               (parallel)
├── macos            (parallel, darwin only)
├── ssh              (parallel)
├── machine          (parallel)
└── mas              (parallel, darwin only)
```

### Bootstrap

Full fresh-machine sequence (`mise/tasks/dotfiles/bootstrap`):

1. Load `~/.dotfiles` overrides
2. Clone repo with `--separate-git-dir`
3. Write `.git` pointer file
4. Set `advice.addIgnoredFile = false`
5. Source `env.sh` directly from checkout
6. Run `dotfiles:machine` (interactive hostname setup)
7. Install mise if missing
8. Run `dotfiles:install`
9. Run `dotfiles:doctor` to verify
