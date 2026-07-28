# Dotfiles

XDG-compliant dotfiles managed as a bare git repo.
The worktree is `$DOTFILES_DIR` (typically `$XDG_CONFIG_HOME` or `~/.config`)
and the git directory lives at `$DOTFILES_GIT`
(typically `$XDG_DATA_DIR/dotfiles.git` or `~/.local/share/dotfiles.git`).
Use `git` directly from the worktree for repo operations.

See [`.github/DESIGN.md`](../.github/DESIGN.md) for detailed system architecture and design rationale.

## Directory layout

| Directory       | Purpose                                                         |
| --------------- | --------------------------------------------------------------- |
| `shell/`        | Shared env (`env.sh`, `interactive.sh`) + bash/zsh dirs         |
| `mise/`         | Tool versions (`config.toml`), tasks, and hooks                 |
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
| `.config/`      | hk pipeline (`hk.pkl`) + linter sidecars (shellcheck, rumdl, typos) |
| `starship.toml` | Starship prompt config                                          |

## Tooling: mise-first approach

When adding a new CLI tool or runtime:

1. **Prefer mise** — add it using `mise use --global <tool>`.
   Perform a fuzzy search for native support using `mise search <tool>`.
   If not found, it may be supported using the github or gitlab backends, the http backend, or a language backend.
   This includes many GUI apps and fonts.
2. **System libraries / build deps** —
   shared libraries and bootstrap tools (`openssl@3`, `pkgconf`, `bash`, `git`, `zsh`) go in `[bootstrap.packages]`.
   Machine-global packages live in `mise/config.toml`;
   macOS-only packages (including the `mas` CLI) in `mise/config.macos.toml`;
   per-machine packages in `mise/config.<machine>.toml`
   (both auto-loaded via `auto_env`/`MISE_ENV` — see `mise/miserc.toml`).
   mise pours Homebrew bottles directly (no `brew` needed);
   install with `mise bootstrap packages install` (wired into `install:mise:system-packages`).
3. **GUI casks** —
   a Homebrew cask installs as a `brew-cask:` entry in `[bootstrap.packages]`
   (macOS-only → `mise/config.macos.toml`), poured by mise without the `brew` CLI:
   mise copies `.app` bundles with `ditto` (preserving the code-signature seal),
   installs `pkg` casks via `sudo installer -pkg`,
   and links font casks straight into `~/Library/Fonts`.
   `claude`, `tailscale-app`, and `font-jetbrains-mono-nerd-font` install this way
   (the font route was broken in mise 2026.7.0 — `invalid font target '/$HOME/Library/Fonts/…'` —
   fixed in 2026.7.1).
   A GUI app that ships a notarized `.app` in a DMG does *not* need a cask —
   install it as a `github:`/`http:` tool with the `install-app` hook (see below),
   as obsidian and steam do in `config.caladan.toml`.

Most tools live in `mise/config.toml`.

If the tool supports shell completions,
add a `postinstall` hook in `mise/config.toml` that calls `mise/hooks/completions`
to generate bash and zsh completions.

If installing a macOS GUI app,
add a `postinstall` hook in `mise/config.toml` that calls `mise/hooks/install-app`
to move the .app to `~/Applications`.

If installing a font available as a Homebrew cask,
declare it as a `brew-cask:font-*` entry in `[bootstrap.packages]`
(macOS-only → `mise/config.macos.toml`) — mise links it into `~/Library/Fonts` itself, no hook needed.
This is how the JetBrains Mono Nerd Font installs.
For a font with no Homebrew cask,
fall back to a `github:`/`http:` tool with a `postinstall` hook in `mise/config.toml`
that calls `mise/hooks/install-fonts` to move the font files to the user's font store.

## Conventions

- **XDG compliance** — configs go in their proper `XDG_CONFIG_HOME` subdirectory.
  Never pollute `$HOME` with dotfiles.
- **Symlinks** — declared in mise's `[dotfiles]` tables
  (`mise/config.toml`, per-machine in `config.<machine>.toml`),
  applied by `install:symlinks` (`mise dotfiles apply`)
  and checked by `doctor:symlinks` (`mise dotfiles status`).
  Add a symlink by adding a `[dotfiles."~/target"]` entry, not by editing a shell library.
- **macOS defaults** — scalar `defaults write` preferences go in `[bootstrap.macos.defaults]`
  (`mise/config.toml`, per-machine in `config.<machine>.toml`).
  Keys you want kept at the macOS default (`defaults delete`)
  and the `killall_targets` restart map stay in `macos/settings.sh`;
  settings with no `defaults` equivalent are documented in `macos/manual.md`.
  mise can't express absent keys, arrays, or app restarts, so those never go in the TOML.
- **Login shell** — declared in `[bootstrap.user].login_shell`
  (`mise/config.macos.toml`; Homebrew zsh, macOS-only since the path is arch-specific).
  Applied by `install:login-shell`
  (`mise bootstrap user apply`: registers it in `/etc/shells` via a one-time sudo, then `chsh`)
  and checked by `doctor:login-shell` (`status --missing`).
  Both skip when no `[bootstrap.user]` entry loads.
- **Commit messages** — conventional commits: `type(scope): description`
  (e.g., `feat(mise): add ripgrep`, `fix(zsh): override HISTFILE`).
- **Shell config split** — `shell/env.sh` holds environment variables
  (sourced by both `.zshenv` and `bash_env`).
  `shell/interactive.sh` holds aliases, functions, and interactive setup
  (sourced by `.zshrc` and `.bashrc`).
  Bash- and zsh-specific files live under `shell/bash/` and `shell/zsh/`.
- **Performance** — expensive shell activations (direnv, fzf, starship, zoxide) are cached.
  Homebrew paths are hardcoded in `env.sh` to avoid `brew shellenv` overhead.

## Code quality (hk)

[hk](https://hk.jdx.dev) runs the formatters, linters, and secret scanning.
Config lives in `.config/`:

- **`hk.pkl`** — pipeline definition (steps + `check`/`fix`/`pre-commit`/`pre-push` hooks),
  pkl amending hk's `Config.pkl`.
  hk discovers this itself — `.config/hk.pkl` is in its default search path, so no `HK_FILE` needed.
- **`shellcheckrc`, `rumdl.toml`, `typos.toml`** — per-tool sidecars.
  These *are* passed explicitly (`--rcfile`, `--config`) from the steps in `hk.pkl`,
  since the tools' own auto-discovery doesn't look in this subdir.

Every tool (`hk`, `shellcheck`, `shfmt`, `taplo`, `rumdl`, `yamlfmt`, `typos`, `gitleaks`) installs via mise.
`hk check` lints staged files and `hk fix` auto-formats them (default scope);
add `--all` to sweep the whole tree (drift check / CI).
Git hooks are wired in `git/config` (`[hook]` entries → `hk run <event> --from-hook`);
export `HK=0` to bypass.

- **Scope is only files we own** — formatters and linters carry an `exclude` list (`notOurs` in `hk.pkl`):
  app-managed and generated files (`gh/hosts.yml`, `claude/settings.json`, Claude memory, `obsidian/`, `.github/TASKS.md`, …)
  are skipped so we don't fight the owning app or churn generated output.
  Shell steps use an explicit glob (extensionless `bin/`, mise tasks/hooks).
  zsh is excluded — shfmt/shellcheck don't support it.
- **Secret scanning is the exception — it scans everything.**
  `gitleaks` runs in `git` mode (reads committed blobs),
  so it's structurally blind to the multi-GB gitignored/untracked trees under the worktree
  while still covering every committed line.
- **shellcheck overrides go at the call site, not the rcfile.**
  `shellcheckrc` carries only `external-sources=true` (illegal in-file).
  Everything else stays a local directive so the check stays live elsewhere:
  `# shellcheck source=SCRIPTDIR/…` (or `=/dev/null`) before each `source`,
  `# shellcheck shell=bash` atop shebang-less sourced files,
  and targeted `# shellcheck disable=` with a reason.

See [`.github/DESIGN.md`](../.github/DESIGN.md) §10 for the full rationale.

## Sensitive files

Never commit secrets. Use `.gitignore` to exclude them.

Secrets are managed at runtime through `fnox` (macOS Keychain),
and `gitleaks` (via hk) blocks committed/pushed secrets — see [Code quality (hk)](#code-quality-hk).

## Mise tasks

Automation uses `mise run` with tasks defined in `.config/mise/tasks/` —
a project-local mise scope, available anywhere under `$DOTFILES_DIR` but not globally
(see [`.github/DESIGN.md`](../.github/DESIGN.md) §9).
The global `worktree:*` tasks stay in `mise/tasks/`. Key tasks:

| Task               | Purpose                                    |
| ------------------ | ------------------------------------------ |
| `install`      | Install dotfiles (system packages, symlinks, plugins) |
| `update`       | Update dotfiles (mise, system packages, zsh-plugins)  |
| `doctor`       | Run all dotfiles health checks             |
| `catalog:tasks` | Regenerate `.github/TASKS.md` from task Usage specs       |

User-facing tasks carry `#USAGE`/`#MISE description`;
internal subtasks set `#MISE hide=true` so only top-level tasks surface in `mise tasks` and the generated reference.
`.github/TASKS.md` is the full auto-generated listing — regenerate it with `catalog:tasks`, never by hand.
