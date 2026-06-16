# dotfiles

XDG-based dotfiles managed as a bare git repo at `$DOTFILES_DIR`
(typically `$XDG_CONFIG_HOME` or `~/.config`).

## Structure

| Directory       | Purpose                                               |
| --------------- | ----------------------------------------------------- |
| `shell/`        | Bash and Zsh config (env, interactive, completions)   |
| `homebrew/`     | Homebrew `Brewfile` (GUI casks only)                  |
| `mise/`         | mise config, tasks, and hooks                         |
| `git/`          | Git config and ignore                                 |
| `ghostty/`      | Ghostty terminal config                               |
| `helix/`        | Helix editor config                                   |
| `gh/`           | GitHub CLI config and hosts                           |
| `bat/`          | Bat syntax highlighting config                        |
| `lazygit/`      | Lazygit TUI config                                    |
| `claude/`       | Claude Code config: settings, hooks, statusline       |
| `macos/`        | macOS reset-catalog + manual notes (`manual.md`)      |
| `mas/`          | Mac App Store app list                                |
| `fnox/`         | Secret management config (macOS Keychain)             |
| `ssh/`          | SSH config template (symlinked to `~/.ssh/config`)    |
| `bin/`          | Custom scripts (`extract`, `genpass`, `path`, `port`) |
| `.config/`      | hk pipeline + linter sidecars (shellcheck, rumdl, …)  |
| `starship.toml` | Starship prompt config                                |
| `DESIGN.md`     | [System architecture and design rationale](DESIGN.md) |

## Setup

On a fresh machine, bootstrap everything with a single command:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/<user>/dotfiles/main/bin/bootstrap) \
    https://github.com/<user>/dotfiles.git
```

Or clone manually first, then run the bootstrap script (it skips the clone step if the repo already exists):

```sh
git clone --separate-git-dir ~/.local/share/dotfiles.git \
    https://github.com/<user>/dotfiles.git ~/.config

~/.config/bin/bootstrap https://github.com/<user>/dotfiles.git
```

The bootstrap script installs Homebrew, mise, shell symlinks, and zsh plugins.
Open a new shell afterwards to pick up the environment.

### Day-to-day

On an already-configured machine, use mise tasks:

```sh
mise run install   # install brew, mise, symlinks, zsh plugins
mise run update    # update brew, mise, zsh plugins
mise run doctor    # run health checks
```

## Mise Tasks

| Task               | Description                                |
| ------------------ | ------------------------------------------ |
| `install` | Install dotfiles (brew, symlinks, plugins) |
| `update`  | Update dotfiles (brew, mise, zsh-plugins)  |
| `doctor`  | Run all dotfiles health checks             |

See [`TASKS.md`](TASKS.md) for the complete, auto-generated reference of every task
(including the `worktree:` namespace);
regenerate it with `mise run catalog:tasks`.

## Adding Packages

For CLI tools and runtimes, prefer `mise/config.toml`:

```sh
mise use --global <tool>
```

For shared system libraries and build dependencies (e.g. `openssl@3`, `pkgconf`),
use `[bootstrap.packages]` in `mise/config.toml` — mise pours Homebrew bottles directly.
macOS-only packages (including the `mas` CLI) go in `mise/config.macos.toml`;
per-machine packages in `mise/config.<machine>.toml` (both auto-loaded — see `mise/miserc.toml`):

```sh
mise bootstrap packages install
```

GUI apps that ship a notarized `.app` in a DMG (e.g. Obsidian, Steam) install via mise —
a `github:`/`http:` tool in `mise/config.<machine>.toml` with the `install-app` hook
(mounts the DMG, copies the `.app` to `~/Applications`).
Only casks `brew-cask:` can't handle — pkg installers and Electron app bundles it mangles — stay in `homebrew/Brewfile`:

```sh
brew bundle install
```

## macOS Settings

Scalar `defaults write` preferences live in `[bootstrap.macos.defaults]`
(`mise/config.toml`, per-machine in `mise/config.<machine>.toml`); apply and verify with mise:

```sh
mise run install:macos   # apply preferences + reset-catalog
mise run doctor:macos    # check for drift
```

Keys kept at their macOS default (`defaults delete`) and the app-restart map stay in `macos/settings.sh`;
settings with no `defaults` equivalent are documented in `macos/manual.md`.

## Linting & Git Hooks

[hk](https://hk.jdx.dev) orchestrates formatting, linting, and secret scanning.
Config lives in `.config/` (`hk.pkl` plus `shellcheckrc`, `rumdl.toml`, `typos.toml` sidecars);
every tool installs via mise.

```sh
hk check         # lint staged files, non-destructive (default scope)
hk fix           # auto-format staged files
hk check --all   # lint the whole tree — drift check / CI
hk fix --all     # format the whole tree
```

Git hooks delegate to hk via `git/config`:
`pre-commit` formats and lints staged files, and `pre-push` runs the secret scan.
Export `HK=0` to bypass a hook.

Formatters and linters only touch files we own (app-managed and generated files are excluded),
but secret scanning (`gitleaks`, in `git` mode) covers every committed line.
See [`DESIGN.md`](DESIGN.md#10-linting-formatting--secret-scanning-hk) for the full design.

## Login Shell

The login shell is declared in `[bootstrap.user].login_shell`
(`mise/config.macos.toml` — Homebrew zsh, `/opt/homebrew/bin/zsh`), applied and verified with mise:

```sh
mise run install:login-shell   # register in /etc/shells (sudo) + chsh
mise run doctor:login-shell    # check for drift
```

The first apply prompts once for `sudo` to add the shell to `/etc/shells`; afterwards it converges to a no-op.
Open a new login shell for the change to take effect.
