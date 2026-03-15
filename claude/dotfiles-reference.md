# Dotfiles & Shared Tasks Reference

A quick reference for working with the personal dotfiles repo and its mise worktree tasks from any project.

## Bare-Worktree Pattern

**Location:** `~/.config` (the worktree)
**Git directory:** `~/.local/share/dotfiles.git`
**Design:** XDG-compliant, bare git repo using `--separate-git-dir`

This setup enables parallel branch management and easy context switching across projects and configuration versions.

## Worktree Tasks (Daily Use)

The dotfiles provides shared mise worktree tasks for managing parallel development branches:

### Setup & Initialization

- **`worktree:init`** — Bootstrap a bare-worktree repo (one-time setup)

### Branch Management

- **`worktree:branch [branch-name]`** — Create a new worktree for a branch (new or existing)
- **`worktree:list`** — Show all active worktrees with their branches and paths
- **`worktree:branches`** — List available remote branches for quick reference

### Status & Synchronization

- **`worktree:status`** — Monitor all worktrees: shows dirty state, commits ahead/behind remote
- **`worktree:sync [branch]`** — Sync a worktree with remote (fetch + rebase)
- **`worktree:fetch`** — Update all worktree branches from remote

### Code Review & Cleanup

- **`worktree:review [branch]`** — Quick checkout to a branch for review, no permanent worktree
- **`worktree:remove [branch]`** — Delete a worktree and its branch
- **`worktree:prune`** — Clean up stale worktrees and branches

## Common Workflows

### Initial Setup with Worktree

```bash
# One-time initialization of your bare-worktree setup
mise run worktree:init

# Confirm setup
mise run worktree:list
```

### Feature Branch Work

```bash
# Create a new worktree for your feature
mise run worktree:branch feature/my-feature

# Navigate to it and work
cd ~/.config/.worktrees/feature/my-feature
# ... make changes, commit ...

# Check status periodically
mise run worktree:status

# Keep in sync
mise run worktree:sync feature/my-feature
```

### Code Review

```bash
# Quick checkout to a branch for review (no worktree created)
mise run worktree:review feature/colleague-branch

# Review changes, then return to previous context
cd -
```

### Daily Synchronization

```bash
# Fetch latest from remote
mise run worktree:fetch

# Check all worktrees for behind/dirty state
mise run worktree:status

# Sync specific worktree if needed
mise run worktree:sync main
```

### Cleanup

```bash
# List all worktrees to identify ones to remove
mise run worktree:list

# Remove a completed worktree
mise run worktree:remove feature/my-feature

# Prune stale worktrees and branches
mise run worktree:prune
```

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

## Dotfiles Context

### Dotfiles Structure

The dotfiles repo contains:
- **Shell config** (`shell/`) — environment variables, aliases, functions
- **Tool configs** (`mise/`, `brew/`, `git/`, `ghostty/`, etc.)
- **Custom scripts** (`bin/`) — `extract`, `genpass`, `path`, `port`
- **Mise tasks** (`mise/tasks/`) — automation for dotfiles management and worktrees

### Bootstrap & Maintenance Tasks

- **`dotfiles:install`** — Full installation: brew, directories, mise, symlinks, zsh-plugins, SSH config
- **`dotfiles:update`** — Update everything: brew, mise, zsh-plugins
- **`dotfiles:doctor`** — Health check: verify brew, mise, dirs, symlinks, plugins, SSH, machine config

From any project, run dotfiles maintenance tasks:

```bash
# Update the dotfiles
mise run dotfiles:update

# Check dotfiles health
mise run dotfiles:doctor
```

Or cd into the dotfiles directly:

```bash
cd $DOTFILES_DIR
mise run update
mise run doctor
```

### Shell Sourcing

- `shell/env.sh` — environment variables (sourced by all shells)
- `shell/interactive.sh` — aliases, functions, interactive setup (sourced only by login shells)

## Related Resources

- **Full design doc:** `~/.config/.github/DESIGN.md` — Architecture decisions, environment variables, shell load order, bare repo pattern
- **Worktree tasks:** `~/.config/mise/tasks/worktree/` — Individual task definitions
- **Dotfiles tasks:** `~/.config/mise/tasks/dotfiles/` — Individual task definitions
- **Mise config:** `~/.config/mise/config.toml` — Tool versions and configurations
- **Global Claude config:** `~/.claude/CLAUDE.md` — Workflow preferences and tooling strategy
