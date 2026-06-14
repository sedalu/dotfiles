# Mise Tasks

Complete reference for every `mise run` task in this repo,
grouped under the `dotfiles:` and `worktree:` namespaces.
For the day-to-day summary, see the [Mise Tasks table in the README](README.md#mise-tasks).

> [!NOTE]
> This section is generated from each task's Usage spec by
> `mise run dotfiles:catalog:tasks` — do not edit it by hand.

<!-- mise-tasks -->
## `dotfiles:bootstrap`

- **Usage**: `dotfiles:bootstrap [repo-url]`

### Arguments

#### `[repo-url]`

## `dotfiles:catalog:macos`

- **Usage**: `dotfiles:catalog:macos`

Sync macOS defaults catalog from macos-defaults.com

## `dotfiles:catalog:tasks`

- **Usage**: `dotfiles:catalog:tasks`

Regenerate the task reference in .github/TASKS.md

## `dotfiles:doctor`

- **Usage**: `dotfiles:doctor`

Run all dotfiles health checks

## `dotfiles:install`

- **Usage**: `dotfiles:install`

Install dotfiles

## `dotfiles:machine`

- **Usage**: `dotfiles:machine`

Set machine name (OS hostname + DOTFILES_MACHINE)

## `dotfiles:update`

- **Usage**: `dotfiles:update`

Update dotfiles

## `worktree:branch`

Create a worktree for a new or existing remote branch


- **Usage**: `worktree:branch [--from <from>] [--name <name>] <branch>`

### Arguments

#### `<branch>`

### Flags

#### `--from <from>`

#### `--name <name>`

## `worktree:branches`

- **Usage**: `worktree:branches`

List remote branches

## `worktree:fetch`

- **Usage**: `worktree:fetch`

Fetch all branches from origin

## `worktree:init`

Bootstrap a bare-worktree repo (clone URL or convert existing)


- **Usage**: `worktree:init [url]`

### Arguments

#### `[url]`

## `worktree:list`

- **Usage**: `worktree:list`

List all worktrees

## `worktree:prune`

- **Usage**: `worktree:prune`

Prune stale worktree references

## `worktree:remove`

Remove a worktree and prune stale references


- **Usage**: `worktree:remove <n>`

### Arguments

#### `<n>`

## `worktree:review`

Switch the pr/ worktree to a given branch


- **Usage**: `worktree:review <branch>`

### Arguments

#### `<branch>`

## `worktree:status`

- **Usage**: `worktree:status`

Show status of all worktrees (branch, dirty, ahead/behind)

## `worktree:sync`

- **Usage**: `worktree:sync`

Fetch origin and pull all worktrees
<!-- /mise-tasks -->
