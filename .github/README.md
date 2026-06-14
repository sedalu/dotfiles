# dotfiles

XDG-based dotfiles managed as a bare git repo at `$DOTFILES_DIR` (typically `$XDG_CONFIG_HOME` or `~/.config`).

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

The bootstrap script installs Homebrew, mise, shell symlinks, and zsh plugins. Open a new shell afterwards to pick up the environment.

### Day-to-day

On an already-configured machine, use mise tasks:

```sh
mise run dotfiles:install   # install brew, mise, symlinks, zsh plugins
mise run dotfiles:update    # update brew, mise, zsh plugins
mise run dotfiles:doctor    # run health checks
```

## Mise Tasks

| Task               | Description                                |
| ------------------ | ------------------------------------------ |
| `dotfiles:install` | Install dotfiles (brew, symlinks, plugins) |
| `dotfiles:update`  | Update dotfiles (brew, mise, zsh-plugins)  |
| `dotfiles:doctor`  | Run all dotfiles health checks             |

See [`TASKS.md`](TASKS.md) for the complete, auto-generated reference of every task
(including the `worktree:` namespace);
regenerate it with `mise run dotfiles:catalog:tasks`.

## Adding Packages

For CLI tools and runtimes, prefer `mise/config.toml`:

```sh
mise use --global <tool>
```

For shared system libraries and build dependencies (e.g. `openssl@3`, `pkgconf`), use `[bootstrap.packages]` in `mise/config.toml` — mise pours Homebrew bottles directly. macOS-only packages (including the `mas` CLI) go in `mise/config.macos.toml`; per-machine packages in `mise/config.<machine>.toml` (both auto-loaded — see `mise/miserc.toml`):

```sh
mise bootstrap packages install
```

GUI apps that ship a notarized `.app` in a DMG (e.g. Obsidian, Steam) install via mise — a `github:`/`http:` tool in `mise/config.<machine>.toml` with the `install-app` hook (mounts the DMG, copies the `.app` to `~/Applications`). Only casks `brew-cask:` can't handle — pkg installers and Electron app bundles it mangles — stay in `homebrew/Brewfile`:

```sh
brew bundle install
```

## macOS Settings

Scalar `defaults write` preferences live in `[bootstrap.macos.defaults]` (`mise/config.toml`, per-machine in `mise/config.<machine>.toml`); apply and verify with mise:

```sh
mise run dotfiles:install:macos   # apply preferences + reset-catalog
mise run dotfiles:doctor:macos    # check for drift
```

Keys kept at their macOS default (`defaults delete`) and the app-restart map stay in `macos/settings.sh`; settings with no `defaults` equivalent are documented in `macos/manual.md`.

## Login Shell

The login shell is declared in `[bootstrap.user].login_shell` (`mise/config.macos.toml` — Homebrew zsh, `/opt/homebrew/bin/zsh`), applied and verified with mise:

```sh
mise run dotfiles:install:login-shell   # register in /etc/shells (sudo) + chsh
mise run dotfiles:doctor:login-shell    # check for drift
```

The first apply prompts once for `sudo` to add the shell to `/etc/shells`; afterwards it converges to a no-op. Open a new login shell for the change to take effect.
