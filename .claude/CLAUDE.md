# Dotfiles

XDG-compliant dotfiles managed as a bare git repo. The worktree is `$DOTFILES_DIR` (typically `$XDG_CONFIG_HOME` or `~/.config`) and the git directory lives at `$DOTFILES_GIT` (typically `$XDG_DATA_DIR/dotfiles.git` or `~/.local/share/dotfiles.git`). Use `git` directly from the worktree for repo operations.

See [`.github/DESIGN.md`](.github/DESIGN.md) for detailed system architecture and design rationale.

## Directory layout

| Directory       | Purpose                                                         |
| --------------- | --------------------------------------------------------------- |
| `shell/`        | Shared env (`env.sh`, `interactive.sh`) + bash/zsh dirs         |
| `mise/`         | Tool versions (`config.toml`), tasks, and hooks                 |
| `homebrew/`     | Homebrew Brewfile (GUI casks only); brew's XDG config dir       |
| `git/`          | User-level git config and ignore                                |
| `ghostty/`      | Ghostty terminal config                                         |
| `helix/`        | Helix editor config and language servers                        |
| `gh/`           | GitHub CLI config and hosts                                     |
| `bat/`          | Bat syntax highlighting config and themes                       |
| `claude/`       | Claude Code config: settings, hooks, statusline (symlinked to `~/.claude`) |
| `macos/`        | macOS reset-catalog (`settings.sh`) + manual notes (`manual.md`); scalar prefs live in `[bootstrap.macos.defaults]` |
| `fnox/`         | fnox secret management config (macOS Keychain)                  |
| `lazygit/`      | Lazygit TUI config and Catppuccin theme                         |
| `lib/`          | Shell helper libraries                                          |
| `mas/`          | Mac App Store app list                                          |
| `ssh/`          | SSH config template (symlinked to `~/.ssh/config`)              |
| `bin/`          | Custom scripts (`extract`, `genpass`, `path`, `port`)           |
| `starship.toml` | Starship prompt config                                          |

## Tooling: mise-first approach

When adding a new CLI tool or runtime:

1. **Prefer mise** — add it using `mise use --global <tool>`. Perform a fuzzy search for native support using `mise search <tool>`. If not found, it may be supported using the github or gitlab backends, the http backend, or a language backend. This includes many GUI apps and fonts.
2. **System libraries / build deps** — shared libraries and bootstrap tools (`openssl@3`, `pkgconf`, `bash`, `git`, `zsh`) go in `[bootstrap.packages]`. Machine-global packages live in `mise/config.toml`; macOS-only packages (including the `mas` CLI) in `mise/config.macos.toml`; per-machine packages in `mise/config.<machine>.toml` (both auto-loaded via `auto_env`/`MISE_ENV` — see `mise/miserc.toml`). mise pours Homebrew bottles directly (no `brew` needed); install with `mise bootstrap packages install` (wired into `dotfiles:install:mise:system-packages`).
3. **Fall back to Brew** — use `homebrew/Brewfile` only for casks `brew-cask:` can't handle: `pkg` installers and Electron `app` bundles mise mangles into a failed-Gatekeeper state (mise 2026.6.6; revisit as `brew-cask:` matures). A GUI app that ships a notarized `.app` in a DMG does *not* need brew — install it as a `github:`/`http:` tool with the `install-app` hook (see below), as obsidian and steam do in `config.caladan.toml`.

The Brewfile is intentionally small. Most tools live in `mise/config.toml`.

If the tool supports shell completions, add a `postinstall` hook in `mise/config.toml` that calls `mise/hooks/completions` to generate bash and zsh completions.

If installing a macOS GUI app, add a `postinstall` hook in `mise/config.toml` that calls `mise/hooks/install-app` to move the .app to `~/Applications`.

If installing a font, add a `postinstall` hook in `mise/config.toml` that calls `mise/hooks/install-fonts` to move the font files to the users font store.

## Conventions

- **XDG compliance** — configs go in their proper `XDG_CONFIG_HOME` subdirectory. Never pollute `$HOME` with dotfiles.
- **Symlinks** — declared in mise's `[dotfiles]` tables (`mise/config.toml`, per-machine in `config.<machine>.toml`), applied by `dotfiles:install:symlinks` (`mise dotfiles apply`) and checked by `dotfiles:doctor:symlinks` (`mise dotfiles status`). Add a symlink by adding a `[dotfiles."~/target"]` entry, not by editing a shell library.
- **macOS defaults** — scalar `defaults write` preferences go in `[bootstrap.macos.defaults]` (`mise/config.toml`, per-machine in `config.<machine>.toml`). Keys you want kept at the macOS default (`defaults delete`) and the `killall_targets` restart map stay in `macos/settings.sh`; settings with no `defaults` equivalent are documented in `macos/manual.md`. mise can't express absent keys, arrays, or app restarts, so those never go in the TOML.
- **Login shell** — declared in `[bootstrap.user].login_shell` (`mise/config.macos.toml`; Homebrew zsh, macOS-only since the path is arch-specific). Applied by `dotfiles:install:login-shell` (`mise bootstrap user apply`: registers it in `/etc/shells` via a one-time sudo, then `chsh`) and checked by `dotfiles:doctor:login-shell` (`status --missing`). Both skip when no `[bootstrap.user]` entry loads.
- **Commit messages** — conventional commits: `type(scope): description` (e.g., `feature(brew): add Brewfile`, `fix(zsh): override HISTFILE`).
- **Shell config split** — `shell/env.sh` holds environment variables (sourced by both `.zshenv` and `bash_env`). `shell/interactive.sh` holds aliases, functions, and interactive setup (sourced by `.zshrc` and `.bashrc`). Bash- and zsh-specific files live under `shell/bash/` and `shell/zsh/`.
- **Performance** — expensive shell activations (direnv, fzf, starship, zoxide) are cached. Homebrew paths are hardcoded in `env.sh` to avoid `brew shellenv` overhead.

## Sensitive files

Never commit secrets. Use `.gitignore` to exclude them.

Secrets are managed at runtime through `fnox` (macOS Keychain).

## Mise tasks

Automation uses `mise run` with tasks defined in `mise/tasks/`. Key tasks:

| Task               | Purpose                                    |
| ------------------ | ------------------------------------------ |
| `dotfiles:install` | Install dotfiles (brew, system packages, symlinks, plugins) |
| `dotfiles:update`  | Update dotfiles (brew, mise, system packages, zsh-plugins)  |
| `dotfiles:doctor`  | Run all dotfiles health checks             |
