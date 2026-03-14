# dotfiles

XDG-based dotfiles managed as a bare git repo at `$DOTFILES_DIR` (typically `$XDG_CONFIG_HOME` or `~/.config`).

## Structure

| Directory       | Purpose                                             |
| --------------- | --------------------------------------------------- |
| `shell/`        | Bash and Zsh config (env, interactive, completions) |
| `brew/`         | Homebrew `Brewfile`                                 |
| `mise/`         | mise config, tasks, and hooks                       |
| `git/`          | Git config and ignore                               |
| `ghostty/`      | Ghostty terminal config                             |
| `helix/`        | Helix editor config                                 |
| `gh/`           | GitHub CLI config and hosts                         |
| `bat/`          | Bat syntax highlighting config                      |
| `lazygit/`      | Lazygit TUI config                                  |
| `claude/`       | Claude Code workflow notes                          |
| `mas/`          | Mac App Store app list                              |
| `fnox/`         | Secret management config (macOS Keychain)           |
| `ssh/`          | SSH config template (symlinked to `~/.ssh/config`)  |
| `bin/`          | Custom scripts (`extract`, `genpass`, `path`, `port`) |
| `starship.toml` | Starship prompt config                              |

## Setup

On a fresh machine, bootstrap everything with a single command:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/<user>/dotfiles/main/bin/bootstrap) \
    https://github.com/<user>/dotfiles.git
```

Or clone manually first, then run the bootstrap script (it skips the clone step if the repo already exists):

```sh
mkdir -p ~/.local/share
git clone --bare https://github.com/<user>/dotfiles.git ~/.local/share/dotfiles.git
git --git-dir=~/.local/share/dotfiles.git config core.worktree ~/.config
git --git-dir=~/.local/share/dotfiles.git checkout -f

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

## Adding Packages

For CLI tools and runtimes, prefer `mise/config.toml`:

```sh
mise use --global <tool>
```

For system-level dependencies and GUI apps/casks, edit `brew/Brewfile`:

```sh
brew bundle install
```