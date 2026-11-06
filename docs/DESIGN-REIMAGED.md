# Design, reimagined

A greenfield design for this dotfiles repo,
built on what mise does natively as of 2026.11.2.
It describes the target system, not a path to it from the current repo.

## 1. Goals

1. **One command provisions a machine.**
   A clean machine becomes fully configured from a single command,
   and a health check proves it.
2. **Declare once, converge, detect drift.**
   Applying is idempotent,
   and the health check reads the same declarations the apply wrote from.
3. **mise is the control plane.**
   Tools, packages, apps, files, preferences, services, the login shell, and tasks are mise declarations.
   Custom code exists only for a gap mise cannot express, and §13 names every one.
4. **XDG-clean `$HOME`.**
   Nothing lives in `$HOME` that a tool can be told to put elsewhere,
   and each relocated path is classified by its data: config, data, state, or cache.
5. **Layered variation: base → OS → machine.**
   Targets are Apple Silicon macOS and Linux desktops.
   The Linux distribution is not yet chosen.
6. **zsh is the interactive shell; bash runs scripts.**
   Both get the environment and the tools,
   interactive or not.
7. **No secret is ever committed.**
   fnox holds secrets, and gitleaks scans every committed line.
8. **App-owned files are never fought.**
   The repo holds only what we author,
   including just our keys of a file an app also writes.
9. **The repo meets the boldlygo standards.**
   Its own tooling follows them;
   the configuration it ships answers to the machine that uses it.
10. **Workstation tools track `latest`; the pipeline's tools are pinned.**
    Updating a machine never writes to the repo.
11. **Cross-project tooling ships here.**
    Global `worktree:*` and `ref:*` tasks, and the Claude Code configuration.
12. **Fewer symlinks.**
    A direction, not a rule:
    a link is used where it is the right tool, and nowhere by default.

Servers, VMs, and containers are out of scope.
The homelab org manages those with the same mise vocabulary,
as `boldlygo/images` already does for container images.

## 2. Principles

- **The checkout is the source; the machine is the output.**
  Deployed files are copies, so nothing on the machine depends on the checkout's working tree
  except mise's own config directory.
- **Layers are files, not conditionals.**
  Which files load decides what applies to a machine.
  An entry for one OS goes in that OS's file,
  not behind an `os` filter in a shared one.
- **An app's declarations live beside its files.**
  One folder per app holds its tools, packages, deployed files, hooks, and health checks.
- **Apply and check share one declaration.**
  `mise bootstrap` applies,
  and `mise bootstrap status --missing` checks the same tables.
  A step mise cannot check is paired with a `[doctor.checks]` entry that can.
- **Hooks are idempotent and cheap.**
  mise runs every hook on every bootstrap,
  so each one tests before it changes anything.
- **mise 2026.11.2 is the floor.**
  `min_version` in the base config enforces it.

## 3. Layout

```text
~/.local/share/dotfiles/           the checkout
├── global/                        ← ~/.config/mise links here
│   ├── miserc.toml                auto_env
│   ├── config.toml                settings, and tools that have no files to deploy
│   ├── config.macos.toml          macOS-wide packages, preferences, login items
│   ├── config.linux.toml          Linux-wide packages
│   ├── config.caladan.toml        one file per machine
│   ├── conf.d/
│   │   ├── zsh/                   one folder per app
│   │   │   ├── mise.toml
│   │   │   ├── mise.macos.toml
│   │   │   ├── zshenv
│   │   │   ├── zprofile
│   │   │   └── zshrc
│   │   ├── git/
│   │   ├── helix/
│   │   ├── claude/
│   │   └── …
│   ├── libexec/                   executables that hooks and checks call
│   └── tasks/                     global tasks
├── .config/                       the repo's own tooling, per the standards
├── .claude/                       CLAUDE.md for working in this repo
├── .forgejo/                      the pipeline workflow and the Renovate config
├── docs/
└── README.md
```

### The checkout

The checkout lives at `$XDG_DATA_HOME/dotfiles`.
It is a plain clone with `.git` inside it,
which `mise bootstrap --from` and `--update` require.

It is a live installation:
mise writes its global config there whenever `mise use -g` or `mise settings set` runs.
So it commits directly to `main`, under the per-checkout exception `git.md` in the standards describes,
whose named case is a live installation,
and is never a worktree project.
The exception is the human's to grant, once per checkout:

```sh
git config --local defaultBranch.allowDirectCommits true
```

`~/.config` is not a repository.
It is a plain directory of deployed files and app-written state,
so it needs no ignore rules.

### Why `global/`

The directory holding mise's global config must not be named `mise/`, `.mise/`, or `.config/mise/`.
mise searches for those names as *project* config from any directory at or below the checkout root,
and a project config found there outranks the repo's own pinned tools.
`global/` matches no project pattern,
so the global config and the repo's pipeline never see each other.

### The repo's own tooling

The checkout is a standards repo whose subject is `global/`.
`.config/` holds its pipeline exactly as `setup.md` in the standards lays out:
`.config/mise/config.toml` with `conf.d/` fragments per file type and a committed `mise.lock`,
`.config/hk.pkl` with `hk.d/` modules,
and the linter sidecars.
`README.md`, `.claude/CLAUDE.md`, and `docs/` divide as `documentation.md` describes.

## 4. How mise loads it

### The one link

```text
~/.config/mise → ~/.local/share/dotfiles/global
```

`mise bootstrap --config-dir global` creates this link on the first run,
and `mise bootstrap --update` fast-forwards the checkout behind it.
It is the only link into the checkout.

Do not relocate mise with `MISE_CONFIG_DIR` or `MISE_GLOBAL_CONFIG_FILE`.
Both exist only in the environment,
so cron, launchd, and `env -i` silently fall back to the default path.
`MISE_GLOBAL_CONFIG_FILE` also drops `conf.d/` and every environment file.
Keep mise's data, state, and cache directories at their defaults for the same reason.

### Layers

| Layer   | Selected by                                       | Files                                                                    |
| ------- | ------------------------------------------------- | ------------------------------------------------------------------------ |
| Base    | always                                            | `config.toml`, `conf.d/*.toml`, `conf.d/<app>/mise.toml`                 |
| OS      | `auto_env = true` in `miserc.toml`                | `config.{unix,macos,linux}.toml`, `conf.d/<app>/mise.{unix,macos,linux}.toml` |
| Machine | `env` in the untracked `miserc.local.toml`        | `config.<machine>.toml`, `conf.d/<app>/mise.<machine>.toml`              |

`auto_env` also matches `macos-arm64`, `linux-x64`, and `linux-arm64`,
for the rare entry that depends on architecture.
Set it explicitly:
mise warns about the implicit value from 2026.12.0 and turns it on by default in 2027.6.0.

The machine layer is chosen once, at bootstrap,
by `mise -E <machine> bootstrap … --save-env`,
which writes `env = ["<machine>"]` to `~/.config/mise/miserc.local.toml`.
It names the machine it sits on,
so the standards' base `.gitignore` already keeps it out through `*.local.*`.
mise reads it in every context,
so the machine layer holds under cron, launchd, and `env -i` alike —
which an exported variable cannot promise.

mise derives no machine name from the hostname,
and nothing in this design derives one either.
The machine file states its own name wherever a hook or check needs it.

### Modules

Each app is a `conf.d` folder.
mise reads `mise.toml`, `mise.<env>.toml`, and their `.local` variants from it,
and resolves relative `source` paths inside it,
so an app's files and its declarations move together:

```toml
# global/conf.d/zsh/mise.toml
[dotfiles]
"~/.zshenv" = "zshenv"
"~/.config/zsh/.zprofile" = "zprofile"
"~/.config/zsh/.zshrc" = "zshrc"

[bootstrap.repos."{{ xdg_data_home }}/zsh/plugins/fzf-tab"]
url = "https://github.com/Aloxaf/fzf-tab.git"
```

```toml
# global/conf.d/zsh/mise.macos.toml
[bootstrap.packages]
"brew:zsh" = "latest"
```

A folder's OS and machine files load with the matching layer,
so an app that differs on caladan carries `mise.caladan.toml` in its own folder.
Machine-wide declarations that belong to no app go in `config.<machine>.toml`.

Source files carry no leading dot — `zshrc`, not `.zshrc` —
so the module reads plainly and no file is hidden from a listing.

Tools that deploy no files stay in `config.toml`.
A tool gains a folder when it gains a file.

### Merging

- Tables merge by key; a `[tools]` entry is replaced whole by a more local one.
- `[dotfiles]` entries merge by target.
  A more local entry replaces the whole entry,
  and `enabled = false` drops an inherited one.
- Hooks from every loaded file run, global config first.
- `[bootstrap] dotfile_groups` stays unset, so every declared group applies.
  Setting it in any layer would replace the list from every other layer.

Do not use `include`.
It cannot carry `[dotfiles]`, `[tasks]`, or `[settings]`,
which are most of what a module declares.

## 5. Deploying files

`copy` is the default mode:

```toml
# global/config.toml
[settings.dotfiles]
default_mode = "copy"
root = "{{ mise_config_dir }}/conf.d"
```

With that default, an entry for a file we author is one line:
`"~/.config/helix/config.toml" = "config.toml"`.
Every other method is chosen deliberately, by what the target is:

| Method                     | Use it for                                                       | Example                                          |
| -------------------------- | ---------------------------------------------------------------- | ------------------------------------------------ |
| `copy`                     | A file we author whole                                           | `~/.config/helix/config.toml`                    |
| copy group                 | A tree we author whole, pruned when a file leaves it             | `~/.claude/hooks/`                               |
| `template`                 | Content that varies by OS or machine, or embeds a resolved path  | `~/.config/go/env`                               |
| merge edit                 | Our keys inside a JSON, TOML, YAML, or INI file an app also writes | `~/.claude/settings.json`                      |
| `merge = "missing"`        | A default the app may change afterward                           | first-run preferences                            |
| block or line edit         | Our lines inside a text file something else owns                 | —                                                |
| `create_if_missing`        | A file seeded once, then owned by the machine                    | `config.local.toml` overlays                     |
| `fnox`                     | A file that carries a secret                                     | a registry token file                            |
| `symlink`                  | A target that must point outside the checkout                    | `~/Downloads` → iCloud Drive                     |
| `absent`                   | A file a tool drops in `$HOME` despite its XDG redirect          | `~/.lesshst`, `~/.viminfo`                       |
| `[bootstrap.directories]`  | A directory's existence and mode                                 | `~/.ssh` at `0700`                               |
| `[bootstrap.files]`        | A path outside `$HOME`, or one that needs an owner               | —                                                |

### Why copy

- Every target is a real file, as its app expects.
  An app that saves by writing a temporary file and renaming it cannot break a deployment.
- The checkout is a pure source.
  Nothing points into it but mise's config link,
  so its working tree can be mid-edit without the machine noticing.
- A live edit is drift.
  `mise dot status` reports it,
  and the health check fails on it until it is resolved.

### The edit loop

- **Change a file:** edit its source in the checkout,
  review with `mise dot diff`,
  then deploy with `mise dot apply`.
- **Keep a change made in place:** `mise dot add --changed` copies edited targets back into their sources.
  It refuses templates; edit a template's source instead.
- **Discard a change made in place:** `mise dot apply` overwrites it.

`copy` overwrites a live edit without the warning `template` gives.
An attended apply lists every change and defaults to No;
an unattended `--yes` apply does not ask.
So no unattended apply runs over drift:
`dotfiles:update` checks status before it pulls,
when any difference can only be an edit made in place or a source edit not yet applied —
both of which a person resolves (§9).

### Trees

A tree we author whole is a copy group,
because a directory `copy` entry adds files and never removes them,
while a group records what it deployed and prunes a file that leaves the tree:

```toml
# global/conf.d/claude/mise.toml
[dotfile_groups.claude-hooks]
root = "claude/hooks"
target = "~/.claude/hooks"
mode = "copy"
```

A group's relative `root` resolves against `dotfiles.root`, not the declaring folder,
which is why the base config sets `dotfiles.root` to `conf.d`.

### Templates

Templates are Tera v2.
Use one only where content must vary,
and keep it small:
Tera reads `{{`, `{%`, and `{#` anywhere in the file,
and `{#` occurs in ordinary bash as `${#var}`.

Templates never call `exec()`.
`status` and `diff` render templates,
so a command in a template runs on every health check.

### App-owned files

An app's own file never enters the repo whole.
The source holds only our keys,
and a merge edit asserts them on every apply:

```toml
# global/conf.d/claude/mise.toml
[dotfiles."~/.claude/settings.json/ours"]
source = "settings.json"
merge = true
```

Keys the app adds are never drift,
and an app that rewrites the file loses nothing of ours past the next apply.
A merge never deletes:
dropping a key from the source leaves it in the target until it is removed by hand.

A file that holds credentials the app manages, such as `gh`'s `hosts.yml`, is never merged.

### Enforcing XDG

Each tool relocated by an environment variable gets an `absent` entry for its legacy path.
Apply removes a stray file,
and status reports one that reappears,
so a tool that stops honoring its variable fails the health check rather than quietly writing to `$HOME`.

## 6. System state

### Tools and packages

- **`[tools]` first.**
  Every CLI tool and runtime a mise backend supplies is a tool,
  which is cross-platform by construction.
- **`[bootstrap.packages]` for the rest:**
  shells, git, shared libraries, GUI apps, fonts, and App Store apps.
- **macOS:** `brew:` formulae and `brew-cask:` casks,
  in `config.macos.toml` or a module's `mise.macos.toml`.
  Every GUI app installs this way, cmux included —
  no app needs an install hook.
- **Linux:** the distribution's manager (`apt:`, `dnf:`, …),
  in `config.linux.toml` or a module's `mise.linux.toml`,
  chosen when the distribution is.
  A manager that is not present skips itself,
  so entries for a second distribution are harmless.
- **No `brew:` entry in a base or Linux file.**
  mise treats Homebrew as present on Linux,
  and an unfiltered entry would create `/home/linuxbrew` with `sudo`.
- **Fonts:** `brew-cask:font-*` casks, on both systems —
  font-only casks install into `$XDG_DATA_HOME/fonts` on Linux.
  `config.linux.toml` runs `fc-cache` from a `post-packages` hook.
- **App Store apps:** `mas:<id>` entries, each with the app's name as a trailing comment.

Versions are `latest` throughout.
`mise bootstrap --upgrade` moves packages and tools forward,
and removing an entry never uninstalls anything:
`mise bootstrap packages prune` removes undeclared formulae and casks.

### macOS preferences

`config.macos.toml` declares preferences natively:
`[bootstrap.macos.defaults]`,
the named `dock`, `finder`, `keyboard`, and `trackpad` tables,
`[bootstrap.macos.dock] apps` for the Dock's contents,
`[bootstrap.macos.login_items]`,
and `[[bootstrap.macos.defaults_entries]]` for `-currentHost` and nested keys.
A machine's own preferences go in its machine file.

Two needs remain outside mise:
keys kept at their macOS default, which only `defaults delete` expresses,
and restarting only the apps whose preferences changed.
`libexec/macos-defaults` covers both, from a pair of hooks:

```toml
# global/config.macos.toml
[bootstrap.hooks]
pre-defaults = "~/.config/mise/libexec/macos-defaults plan"
post-defaults = "~/.config/mise/libexec/macos-defaults finish"
```

`plan` records the domains `mise bootstrap macos defaults status --json` reports as differing —
exactly the domains the apply is about to write.
`finish` deletes each key on the reset list,
adds the domain of any key it deleted,
and restarts the apps mapped to the recorded domains.
The reset list and the app map are a data file in `conf.d/macos/`,
and a `[doctor.checks]` entry asserts every listed key is absent.

Settings with no `defaults` equivalent are documented in `docs/macos-manual.md`.

### Login shell

```toml
# global/config.toml
[bootstrap.user]
login_shell = "zsh"
```

A bare name resolves after packages install —
Homebrew's zsh on macOS, the distribution's on Linux —
so one declaration serves both systems.
mise registers it in `/etc/shells` and runs `chsh`.

### Services

A background agent is a `[bootstrap.services.<name>]` entry with `scope = "user"`,
which mise writes as a LaunchAgent on macOS and a systemd user unit on Linux.
`[bootstrap.macos.launchd.agents]` and `[bootstrap.linux.systemd.units]` are for features only one platform has,
in that platform's file.

### Repositories

zsh plugins are `[bootstrap.repos]` entries in the zsh module, with no `ref`.
Apply clones a missing checkout and leaves an existing one alone,
`--update` fast-forwards it,
and status needs no network.

### Hostname

mise has no hostname support.
Each machine file names itself:

```toml
# global/config.caladan.toml
[bootstrap.hooks]
pre-packages = "~/.config/mise/libexec/hostname set caladan"

[doctor.checks.hostname]
description = "The OS hostname is caladan"
run = "~/.config/mise/libexec/hostname check caladan"
hint = "Run `mise bootstrap`."
```

`set` writes the three macOS names with `scutil`,
or the static hostname with `hostnamectl`,
and does nothing when they already match.

### SSH

`~/.ssh` is a `[bootstrap.directories]` entry at `0700`,
and `~/.ssh/config` is a copy at `0600`.
Each machine has its own key,
which a `post-dotfiles` hook generates when it is missing,
and which never leaves the machine.

## 7. Shells

### Files

| File                          | Read by                          | Holds                                                     |
| ----------------------------- | -------------------------------- | --------------------------------------------------------- |
| `~/.zshenv`                   | every zsh                        | `ZDOTDIR`, then the shared environment                    |
| `~/.config/zsh/.zprofile`     | login zsh                        | `PATH` restored after macOS's `path_helper`               |
| `~/.config/zsh/.zshrc`        | interactive zsh                  | `mise activate zsh`, completions, plugins, prompt         |
| `~/.bash_profile`             | login bash                       | the shared environment, then `.bashrc`                    |
| `~/.bashrc`                   | interactive bash                 | `mise activate bash`, completions, prompt                 |
| `~/.config/shell/env.sh`      | both, through the files above    | XDG variables, tool relocations, `PATH`, `BASH_ENV`       |
| `~/.config/bash/env`          | non-interactive bash, through `BASH_ENV` | the shared environment                            |
| `~/.config/shell/os.sh`       | `env.sh`, when present           | the OS layer                                              |
| `~/.config/shell/machine.sh`  | `env.sh`, when present           | the machine layer                                         |

`~/.zshenv`, `~/.bash_profile`, and `~/.bashrc` are the only shell files in `$HOME`:
bash has no relocation, and zsh needs one file to learn `ZDOTDIR`.

`os.sh` and `machine.sh` deploy from the shell module's `mise.macos.toml`, `mise.linux.toml`, and `mise.<machine>.toml`,
so the runtime sources fixed names
and no variable names the OS or the machine.

`env.sh` is static and spawns nothing.
It runs for every bash script through `BASH_ENV`,
so it costs only assignments.
Homebrew's paths are written out rather than read from `brew shellenv`.

### Tools in every context

| Context                                   | Tools arrive through                                      |
| ----------------------------------------- | --------------------------------------------------------- |
| Interactive zsh or bash                   | `mise activate`: tools, `[env]`, and directory hooks      |
| A process started from a login shell      | mise's shims, on `PATH` from `env.sh`                     |
| Non-interactive bash                      | `BASH_ENV` → `env.sh` → shims                             |
| A `[bootstrap.services]` agent            | its declared `command`, by absolute path                  |
| `env -i`, cron                            | an absolute path, or `PATH` set in the crontab            |

mise's `[bootstrap.mise_shell_activate]` is not used.
It writes to fixed `~/.zshrc` and `~/.zprofile` paths and ignores `ZDOTDIR`,
and our files are deployed whole, so they carry their activation lines themselves.

### Activation caches

Expensive init scripts — starship, zoxide, fzf, fnox — are cached under `$XDG_CACHE_HOME/<shell>/init/`.
Each tool's `postinstall` regenerates its cache when its version changes,
and the rc file generates it inline when the cache is missing,
so a cleared cache costs one slow start rather than a broken one.

A tool's `postinstall` runs with `MISE_GLOBAL_CONFIG_FILE` pointing at `config.toml` alone,
so a hook that calls `mise` sees no `conf.d/` and no layers.
Hooks read `$MISE_TOOL_INSTALL_PATH` and `$MISE_TOOL_VERSION` instead,
and never `{{ vars }}`.

### Completions

- mise's own: `mise completion zsh --install`, and the same for bash.
- Tools mise installs from `packslip:` — hk, fnox, usage, pitchfork — ship completions mise loads itself.
- Every other tool's `postinstall` calls `libexec/completions`,
  which writes into `$XDG_DATA_HOME/zsh/site-functions` and `$XDG_DATA_HOME/bash/completions`.

### Aliases

Interactive aliases are `[shell_alias]` entries.
They exist only in activated shells,
which is what an alias is for:
a script never sees one.

## 8. Secrets

- fnox holds every secret:
  the macOS Keychain for secrets that never leave the machine,
  age for anything committed.
- A file that carries a secret is a `mode = "fnox"` entry.
  Its content lives in fnox, never in the repo,
  and `mise dot add` refuses to capture it.
- A template that needs a secret declares it in `[bootstrap.secrets]`
  and runs under `fnox exec -- mise bootstrap`.
- fnox's own config is deployed by the fnox module.
  Its age key stays on the machine and is never deployed.
- gitleaks scans every committed blob (§11).

A fresh machine has an empty Keychain and no fnox until the tools phase.
So nothing on the first bootstrap's path may need a secret:
an entry that does is resolved before any change is made,
and a missing value stops the whole run.

## 9. Lifecycle

### A fresh machine

```sh
curl -fsSL https://mise.run | MISE_VERSION=v2026.11.2 sh
~/.local/bin/mise -E caladan bootstrap \
  --from https://github.com/sedalu/dotfiles.git \
  --from-dir ~/.local/share/dotfiles \
  --config-dir global \
  --save-env --yes
```

The first clone comes from the public GitHub mirror over HTTPS,
because a fresh machine has neither the tailnet nor an SSH key to reach the forge.
mise installs git first if the machine has none,
clones the checkout,
creates the config link,
saves the machine's environment,
and applies every part in its own order.

Then, by hand:

1. Log in to Tailscale.
2. Register the machine's SSH key with the forge and with GitHub.
3. Point `origin` at the forge:
   `git -C ~/.local/share/dotfiles remote set-url origin ssh://git@forge.taildfeaeb.ts.net/seth/dotfiles.git`.
4. Grant the checkout its direct-commit exception (§3).
5. Run `dotfiles:doctor`.

A `[doctor.checks]` entry fails until `origin` is the forge,
so a machine left on the mirror is reported, not forgotten.

### Applying

`mise bootstrap` applies everything;
`mise dot apply` applies files only.
Both list their changes and ask first when attended.

### Updating

`dotfiles:update`, a global task:

1. `mise dot status --missing` — stop on any drift, naming each file.
2. `mise self-update` — mise first, so the run that follows meets the floor.
3. `mise bootstrap --update --upgrade --yes` —
   fast-forward the checkout and plugin repositories,
   upgrade packages and tools,
   and apply.

It runs from `$HOME`,
so a trusted project's own `bootstrap` task never joins the run.
Nothing in it writes to the repo:
it only pulls.

### Health

`dotfiles:doctor`, a global task, fails if any of these fail:

1. `mise bootstrap status --missing` —
   every declared part, tools and files included, against the machine.
2. `mise doctor project` —
   every `[doctor.checks]` entry the global config declares,
   with each one's hint.

The checks cover what `status` cannot see:

| Check                 | Declared in              | Asserts                                                          |
| --------------------- | ------------------------ | ---------------------------------------------------------------- |
| `hostname`            | each machine file        | the OS hostname is the machine's name                            |
| `macos:reset-keys`    | `conf.d/macos/`          | every reset-list key is absent                                   |
| `dotfiles:origin`     | `config.toml`            | `origin` is the forge                                            |
| `dotfiles:config`     | `config.toml`            | `mise dot status` prints no warning                              |
| `ssh:key`             | `conf.d/ssh/`            | the machine's key exists                                         |
| `claude:guards`       | `conf.d/claude/`         | each Claude Code guard loads and returns the expected decision   |

`dotfiles:config` exists because mise skips an invalid `[dotfiles]` entry or an unknown key with only a warning,
which `status --missing` does not count.

## 10. Tasks

### Global

`global/tasks/` is `$MISE_CONFIG_DIR/tasks`, so its tasks run from any directory:

| Task               | Does                                       |
| ------------------ | ------------------------------------------ |
| `dotfiles:update`  | Update this machine (§9)                   |
| `dotfiles:doctor`  | Check this machine (§9)                    |
| `worktree:*`       | Drive the sibling-worktree layout          |
| `ref:*`            | Clone and refresh reference checkouts      |

A project task with the same name shadows a global one,
so every global task carries a prefix no project uses.
A task that acts on the caller's directory sets `dir = "{{cwd}}"`,
since a global task otherwise runs in `$HOME`.

No global task is named `bootstrap`.
mise runs a task by that name on every `mise bootstrap`,
so imperative steps live in hooks, owned by the module they serve.

### Repo

`.config/mise/tasks/` holds the standards' entry points,
visible only inside the checkout:

| Task                  | Does                                                                   |
| --------------------- | ---------------------------------------------------------------------- |
| `check`, `fix`        | The pipeline, with `:staged`, `:all`, and `:pr` scopes                 |
| `pre-commit`, `pre-push` | What the git hooks invoke                                           |
| `generate`            | Every generated file, through its children                             |
| `generate:tasks`      | `docs/TASKS.md`, global tasks included                                 |
| `generate:macos`      | The macOS reset list's catalog data                                    |
| `test:e2e`            | The end-to-end tier, through its children                              |
| `test:e2e:linux`      | A fresh bootstrap of the Linux layer in a container                    |

`check`, `fix`, the hook tasks, and the `generate` and `test:e2e` aggregates come from the standards' base config unchanged;
the repo adds only children.

`generate:tasks` reads `mise tasks ls --json` for both scopes,
since `mise generate task-docs` skips global tasks.

`test:e2e:linux` proves goal 1 on Linux:
it runs the fresh-machine command against the checkout in a Linux container
and passes only if `dotfiles:doctor` does.
It runs on a workstation, not in CI —
see §11.

## 11. Quality pipeline

The pipeline is the standards' base with the Markdown, YAML, TOML, JSON, and shell modules.

- **Pins.** `.config/mise/config.toml` pins every pipeline tool exactly,
  with `lockfile = true`, `tool_config.locked = true`,
  and `lockfile_platforms` covering `macos-arm64`, `linux-x64`, and `linux-arm64`.
  The workstation's `latest` tools live in `global/` and never reach this lockfile.
- **Hooks.** The git module deploys the user's git config,
  whose `hook` entries dispatch to hk for every repo on the machine,
  with `HK_MISE=1` set in the pipeline's config.
- **Scope.** Everything under `global/` is ours, so every formatter and linter covers it.
  App-owned files never enter the repo,
  so `notOurs` holds only vendor-generated output.
  Shell steps name their files explicitly — `global/libexec/`, both task directories, and the bash and shared shell sources —
  and zsh sources stay out, since neither shellcheck nor shfmt reads zsh.
- **Secrets.** gitleaks runs in `git` mode, over every committed blob.
- **CI.** `.forgejo/workflows/pipeline.yaml` is the standards' file, copied unchanged:
  the `pipeline` workflow, whose one job, `check`, runs `check:all`
  in the shared `forge.taildfeaeb.ts.net/boldlygo/runner` image.
  Every tool arrives from the lockfile, and Renovate bumps the image's tag.
  The repo releases nothing, so it has no `release` job.
  `test:e2e` stays off the runner:
  the standards' pipeline runs `check:all` and nothing else,
  and an image that already carries mise is not a fresh machine.
- **Protection.** `main` on the forge requires `pipeline / check (pull_request)`,
  so Renovate's automerge waits for the check
  instead of merging the moment the pull request opens.
  Commits from the live checkout still push straight to `main`.
- **Renovate.** `.forgejo/renovate.json5` only extends the standards' `base.json5` preset.

## 12. Claude Code

`~/.claude` stays Claude Code's own directory:
its sessions, projects, and caches are app state, not configuration.
The claude module deploys our files into it:

| Target                          | Method                 |
| ------------------------------- | ---------------------- |
| `~/.claude/CLAUDE.md`           | copy                   |
| `~/.claude/statusline-command.sh` | copy                 |
| `~/.claude/hooks/`              | copy group             |
| `~/.claude/skills/`             | copy group             |
| `~/.claude/settings.json`       | merge edit, our keys   |

The `claude:guards` check drives each guard end to end,
because a guard that cannot load fails open,
and an open guard looks exactly like a session with nothing to block.

Leave `skills.auto_sync` off.
It would link packslip tools' skills into `~/.claude/skills`,
a directory the claude module owns.

## 13. Remaining custom code

Each entry is a gap in mise, and is retired when mise closes it.

| Gap                                                | Code                                          | Retire when mise                                     |
| -------------------------------------------------- | --------------------------------------------- | ---------------------------------------------------- |
| Keys kept at their macOS default                   | `libexec/macos-defaults`, `pre`/`post-defaults` hooks | declares an absent default                   |
| Restarting only apps whose preferences changed     | the same                                      | restarts on change, or tells hooks what changed      |
| Setting the hostname                               | `libexec/hostname`, a `pre-packages` hook     | manages the hostname                                 |
| Completions for tools outside `packslip:`          | `libexec/completions`, tool `postinstall`     | installs completions for every backend               |
| Cached shell init                                  | tool `postinstall`                            | caches init output                                   |
| `fc-cache` after Linux font installs               | a `post-packages` hook                        | refreshes the font cache                             |
| A per-machine SSH key                              | a `post-dotfiles` hook                        | never — the key is the machine's own                 |
| Applying over a live edit unattended               | `dotfiles:update`'s status check              | refuses or warns on edited copies, as for templates  |
| A task catalog that includes global tasks          | `generate:tasks`                              | covers global tasks in `generate task-docs`          |
| A service that runs from a versioned install       | the Apple `container` tool's `postinstall`    | — specific to that tool                              |

## 14. Upcoming mise changes

| Version    | Change                                                          | Response                                        |
| ---------- | --------------------------------------------------------------- | ----------------------------------------------- |
| 2026.12.0  | Warns when `auto_env` is implicit                               | set explicitly in `miserc.toml`                 |
| 2027.4.0   | Removes Tera v1                                                 | templates are written for v2                    |
| 2027.6.0   | `auto_env` on by default                                        | none; already set                               |
| 2027.8.10  | `conf.d` filename suffixes select environments                  | single-file fragment names carry no dots        |
| 2027.10.4  | Removes the legacy bootstrap part names                         | scripts and docs use the current names          |
| announced  | `*` in dotfiles `exclude` patterns stops crossing `/`           | write `**` where a pattern spans directories    |

## 15. Open questions

1. **App Store apps on the first run.**
   Packages install before tools,
   so `mas:` entries skip on a fresh machine when `mas` comes from `[tools]`.
   Install `mas` as `brew:mas` instead, or accept a second run?
2. **fnox-backed files on the first run.**
   fnox installs in the tools phase, after files deploy.
   Gate secret-bearing entries behind an environment that a machine adds once its keys exist?
3. **Executable bits.**
   Confirm a copy keeps its source's mode,
   or declare `permissions` on every script a group deploys.
4. **`mise.toml` inside module folders.**
   From a directory inside a module, mise also finds its `mise.toml` as project config,
   which loads it twice and asks for trust.
   Confirm the effect is only that,
   and work from the checkout root.
5. **Renovate and module files.**
   Its mise manager matches `mise.toml` anywhere,
   so it reads every module's `latest` entries.
   Confirm it skips them, or ignore `global/`.
6. **The templated `dotfiles.root`.**
   Confirm groups resolve `{{ mise_config_dir }}/conf.d` through the config link.
7. **Workstation versions.**
   `tooling.md` in the standards holds a personal global config to the minor line,
   where goal 10 says `latest`.
   Keep `latest`, or adopt minor lines?
8. **The Linux distribution.**
   Its package manager, desktop apps, and services fill `config.linux.toml` once it is chosen.
9. **End-to-end tests in CI.**
   The standards define the end-to-end tier but give `pipeline` no job that runs it.
   Until they do, `test:e2e:linux` proves goal 1 only when someone runs it.
10. **The exception and the protection rule.**
    `git.md` treats the direct-commit exception and a protected default branch as one decision,
    where granting one forgoes the other.
    This repo needs both:
    direct commits from the live checkout,
    and a required check for Renovate's automerge to wait on.
    Record the combination in the standards, or route Renovate's updates some other way?
