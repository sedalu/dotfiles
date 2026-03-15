# Dotfiles & Shared Tasks Reference

A quick reference for working with the personal dotfiles repo and its mise worktree tasks from any project.

## Dotfiles Repo Overview

**Location:** `~/.config` (the worktree)
**Git directory:** `~/.local/share/dotfiles.git`
**Design:** XDG-compliant, bare git repo using `--separate-git-dir`

The dotfiles repo contains:
- **Shell config** (`shell/`) — environment variables, aliases, functions
- **Tool configs** (`mise/`, `brew/`, `git/`, `ghostty/`, etc.)
- **Custom scripts** (`bin/`) — `extract`, `genpass`, `path`, `port`
- **Mise tasks** (`mise/tasks/`) — automation for dotfiles management

See `~/.config/.github/DESIGN.md` for architecture details and design rationale.

## Environment Variables

When working from any project, these variables are available from your dotfiles setup:

| Variable        | Typical Value                | Purpose                                    |
| --------------- | ---------------------------- | ------------------------------------------ |
| `DOTFILES_DIR`  | `~/.config`                  | Dotfiles worktree location                 |
| `DOTFILES_GIT`  | `~/.local/share/dotfiles.git` | Git directory (for worktree operations)   |
| `DOTFILES_MACHINE` | Normalized hostname          | Machine identifier (e.g., `my-macbook`)  |
| `DOTFILES_OS`   | `darwin` or `linux`          | OS identifier                              |
| `DOTFILES_SHELL` | `bash` or `zsh`             | Current shell name                         |

Use `echo $DOTFILES_DIR` to confirm the dotfiles location in your current shell.

## Key Mise Tasks

The dotfiles repo provides shared mise tasks for managing the dotfiles setup:

### Install & Bootstrap

- **`dotfiles:install`** — Full installation: brew, directories, mise, symlinks, zsh-plugins, SSH config
- **`dotfiles:machine`** — Interactive setup: configure machine name, machine-specific symlinks

### Maintenance

- **`dotfiles:update`** — Update everything: brew, mise, zsh-plugins
- **`dotfiles:doctor`** — Health check: verify brew, mise, dirs, symlinks, plugins, SSH, machine config

### Running Tasks from Any Project

From any project, you can run dotfiles tasks using the global mise:

```bash
# Update the dotfiles
mise run dotfiles:update

# Check dotfiles health
mise run dotfiles:doctor

# Reconfigure machine-specific settings
mise run dotfiles:machine
```

Alternatively, cd into the dotfiles and run directly:

```bash
cd $DOTFILES_DIR
mise run install
mise run doctor
```

## Quick Examples

### Finding Your Dotfiles Location
```bash
echo $DOTFILES_DIR       # Usually ~/.config
cd $DOTFILES_DIR
git status               # Works normally from the worktree
```

### Adding a New Config to Dotfiles
1. Place the file in `~/.config/<tool>/`
2. Commit with `git add -f ~/.config/<tool>/<file>`
3. Run `mise run dotfiles:doctor` to verify setup

### Checking Dotfiles Health
```bash
mise run dotfiles:doctor
```

This verifies:
- Homebrew and mise tools
- XDG directories exist
- Symlinks are correct
- Zsh plugins installed
- SSH config valid
- Machine name configured

### Updating After Changes to dotfiles
```bash
mise run dotfiles:update
# or from the dotfiles directory:
cd $DOTFILES_DIR && mise run update
```

## Workflow Tips

**From a project, update dotfiles without switching directories:**
```bash
# Works from any project
mise run dotfiles:update

# More verbose:
DOTFILES_GIT=~/.local/share/dotfiles.git git -C $DOTFILES_DIR status
```

**Machine-specific config:**
If you need machine-specific dotfiles additions, they're supported via sidecar files and the `DOTFILES_MACHINE` variable. See the design doc (§5) for details.

**Shell sourcing:**
- `shell/env.sh` — environment variables (sourced by all shells)
- `shell/interactive.sh` — aliases, functions, interactive setup (sourced only by login shells)

## Related Resources

- **Full design doc:** `~/.config/.github/DESIGN.md` — Architecture decisions, environment variables, shell load order, bare repo pattern
- **Dotfiles tasks:** `~/.config/mise/tasks/dotfiles/` — Individual task definitions
- **Mise config:** `~/.config/mise/config.toml` — Tool versions and configurations
- **Global Claude config:** `~/.claude/CLAUDE.md` — Workflow preferences and tooling strategy
