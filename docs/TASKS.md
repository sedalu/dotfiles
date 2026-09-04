# Mise Tasks

Complete reference for every `mise run` task in this repo:
the tree-scoped dotfiles-management tasks and the global `worktree:*` tasks.
For the day-to-day summary, see the [Mise Tasks table in the README](../README.md#mise-tasks).

> [!NOTE]
> This section is generated from each task's Usage spec by
> `mise run catalog:tasks` — do not edit it by hand.

<!-- mise-tasks -->
## `bootstrap`

Bootstrap dotfiles on a fresh machine


- **Usage:** `bootstrap [repo-url]`

### Arguments
- **`[repo-url]`**

## `catalog:macos`

- **Usage:** `catalog:macos`

Sync macOS defaults catalog from macos-defaults.com

## `catalog:tasks`

- **Usage:** `catalog:tasks`

Regenerate the task reference in docs/TASKS.md

## `check`

- Depends: check:staged

- **Usage:** `check`

Check the default scope — the staged set

## `check:all`

- **Usage:** `check:all`

Check the whole tree — what CI runs

## `check:pr`

- **Usage:** `check:pr`

Check the diff against the default branch

## `check:staged`

- **Usage:** `check:staged`

Check the staged set

## `doctor`

- **Usage:** `doctor`

Run all dotfiles health checks

## `fix`

- Depends: fix:staged

- **Usage:** `fix`

Fix the default scope — the staged set

## `fix:all`

- **Usage:** `fix:all`

Fix the whole tree

## `fix:pr`

- **Usage:** `fix:pr`

Fix the diff against the default branch

## `fix:staged`

- **Usage:** `fix:staged`

Fix the staged set

## `install`

- **Usage:** `install`

Install dotfiles

## `machine`

- **Usage:** `machine`

Set machine name (OS hostname + DOTFILES_MACHINE)

## `update`

- **Usage:** `update`

Update dotfiles

## `worktree:branch`

Create a worktree for a new or existing remote branch


- **Usage:** `worktree:branch [--from <from>] [--name <name>] <branch>`

### Arguments
- **`<branch>`**

### Flags
- **`--from <from>`**
- **`--name <name>`**

## `worktree:branches`

- **Usage:** `worktree:branches`

List remote branches

## `worktree:fetch`

- **Usage:** `worktree:fetch`

Fetch all branches from origin

## `worktree:init`

Bootstrap a bare-worktree repo (clone URL or convert existing)


- **Usage:** `worktree:init [url]`

### Arguments
- **`[url]`**

## `worktree:list`

- **Usage:** `worktree:list`

List all worktrees

## `worktree:prune`

- **Usage:** `worktree:prune`

Prune stale worktree references

## `worktree:remove`

Remove a worktree and prune stale references


- **Usage:** `worktree:remove <n>`

### Arguments
- **`<n>`**

## `worktree:review`

Switch the pr/ worktree to a given branch


- **Usage:** `worktree:review <branch>`

### Arguments
- **`<branch>`**

## `worktree:status`

- **Usage:** `worktree:status`

Show status of all worktrees (branch, dirty, ahead/behind)

## `worktree:sync`

- **Usage:** `worktree:sync`

Fetch origin and pull all worktrees
<!-- /mise-tasks -->
