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
| `lib/dotfiles/symlinks.sh` | `lib/dotfiles/symlinks.${MACHINE}.sh`      | `symlinks.caladan.sh`          |
| `mas/apps`                 | `mas/apps.${MACHINE}`                      | `mas/apps.caladan`             |
| `macos/settings.sh`        | `macos/settings.${MACHINE}.sh`             | `settings.caladan.sh`          |

The base `symlinks.sh` auto-loads its sidecar and appends `dotfiles_machine_symlinks` to the main array.

Example: `symlinks.caladan.sh` adds `~/Downloads` → iCloud Drive Downloads.

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
| `symlinks.sh`       | Base symlink `link:target` pairs            | install:symlinks, doctor:symlinks        |
| `dirs.sh`           | XDG directories to create/verify            | install:dirs, doctor:dirs                |
| `hostname.sh`       | `get_hostname`, `normalize_hostname`        | machine, install:mas, env.sh             |
| `zsh-plugins.sh`    | Plugin `name:url` pairs, `ZSH_PLUGINS_DIR` | install:zsh-plugins, doctor:zsh-plugins  |
| `go.sh`             | Go XDG-compliant paths                      | install:go, doctor:go                    |

macOS settings live in `macos/` (not `lib/`). Each line is a real `defaults write` command — no DSL or array parsing needed. Shared helpers in `lib/dotfiles/macos.sh` handle parsing and comparison for both tasks:

| Config file             | Defines                                     | Used by                                  |
| ----------------------- | ------------------------------------------- | ---------------------------------------- |
| `macos/settings.sh`     | `defaults write` commands + `killall_targets` mapping | install:macos, doctor:macos  |
| `lib/dotfiles/macos.sh` | Shared parsing and comparison helpers       | install:macos, doctor:macos              |

Machine-specific sidecars (e.g., `symlinks.caladan.sh`, `settings.caladan.sh`) extend the base definitions automatically.

## 8. Symlink System

### Base Symlinks

Defined in `lib/dotfiles/symlinks.sh` as `link:target` pairs:

| Link                    | Target                                   |
| ----------------------- | ---------------------------------------- |
| `~/.claude`             | `$DOTFILES_DIR/claude`                   |
| `~/.bash_profile`       | `$DOTFILES_DIR/shell/bash/.bash_profile` |
| `~/.bashrc`             | `$DOTFILES_DIR/shell/bash/.bashrc`       |
| `~/.zshenv`             | `$DOTFILES_DIR/shell/zsh/.zshenv`        |
| `~/.ssh/config`         | `$DOTFILES_DIR/ssh/config`               |

### Conflict Resolution

The symlink installer (`mise/tasks/dotfiles/install/symlinks`) handles conflicts:

| Existing state         | Action                                              |
| ---------------------- | --------------------------------------------------- |
| Correct symlink        | Skip                                                |
| Wrong symlink          | Remove and recreate                                 |
| Empty directory        | Remove and replace with symlink                     |
| Non-empty directory    | Rename to `.bak`, create symlink                    |
| Regular file           | Rename to `.bak`, create symlink                    |

For macOS protected directories (e.g., `~/Downloads` with deny-delete ACLs), the installer strips the ACL before removal and restores it on failure.

## 9. Mise Task Orchestration

All automation runs through `mise run` with tasks in `mise/tasks/dotfiles/`.

### Install Dependencies

```
dotfiles:install
├── brew             (parallel)
├── dirs             (parallel)
├── mise             (parallel)
├── go               (parallel)
├── macos            (parallel, darwin only)
├── symlinks         (parallel)
├── zsh-plugins      (parallel)
├── mas              (parallel, darwin only)
└── ssh              (depends: symlinks)
```

### Update Dependencies

```
dotfiles:update
├── brew
├── mise             (depends: brew)
├── macos            (parallel, darwin only)
├── zsh-plugins      (parallel)
└── mas              (parallel, darwin only)
```

### Doctor Dependencies

```
dotfiles:doctor
├── tools
├── brew             (depends: tools)
├── mise             (depends: tools)
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
