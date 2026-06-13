# Dotfiles

XDG-compliant dotfiles managed as a bare git repo. The worktree is `$DOTFILES_DIR` (typically `$XDG_CONFIG_HOME` or `~/.config`) and the git directory lives at `$DOTFILES_GIT` (typically `$XDG_DATA_DIR/dotfiles.git` or `~/.local/share/dotfiles.git`). Use `git` directly from the worktree for repo operations.

See [`.github/DESIGN.md`](.github/DESIGN.md) for detailed system architecture and design rationale.

## Directory layout

| Directory       | Purpose                                                         |
| --------------- | --------------------------------------------------------------- |
| `shell/`        | Shared env (`env.sh`, `interactive.sh`) + bash/zsh dirs         |
| `mise/`         | Tool versions (`config.toml`), tasks, and hooks                 |
| `homebrew/`     | Homebrew Brewfile (casks and Mac App Store CLI only); brew's XDG config dir |
| `git/`          | User-level git config and ignore                                |
| `ghostty/`      | Ghostty terminal config                                         |
| `helix/`        | Helix editor config and language servers                        |
| `gh/`           | GitHub CLI config and hosts                                     |
| `bat/`          | Bat syntax highlighting config and themes                       |
| `claude/`       | Claude Code config: settings, hooks, statusline (symlinked to `~/.claude`) |
| `macos/`        | macOS defaults settings (`settings.sh`, per-machine sidecars, `catalog.sh`) |
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
2. **System libraries / build deps** — shared libraries and bootstrap tools (`openssl@3`, `pkgconf`, `bash`, `git`, `zsh`) go in `[bootstrap.packages]` in `mise/config.toml`. mise pours Homebrew bottles directly (no `brew` needed); install them with `mise bootstrap packages install` (wired into `dotfiles:install:mise:system-packages`).
3. **Fall back to Brew** — use `homebrew/Brewfile` only for things mise cannot manage: casks (GUI apps, fonts) and the Mac App Store CLI (`mas`).

The Brewfile is intentionally small. Most tools live in `mise/config.toml`.

If the tool supports shell completions, add a `postinstall` hook in `mise/config.toml` that calls `mise/hooks/completions` to generate bash and zsh completions.

If installing a macOS GUI app, add a `postinstall` hook in `mise/config.toml` that calls `mise/hooks/install-app` to move the .app to `~/Applications`.

If installing a font, add a `postinstall` hook in `mise/config.toml` that calls `mise/hooks/install-fonts` to move the font files to the users font store.

## Conventions

- **XDG compliance** — configs go in their proper `XDG_CONFIG_HOME` subdirectory. Never pollute `$HOME` with dotfiles.
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
