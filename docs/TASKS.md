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
- **`[repo-url]`** — URL of the dotfiles git repository (or set DOTFILES_REPO in ~/.dotfiles)

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

## `ref:get`

Clone or refresh a reference checkout and print its path


- **Usage:** `ref:get <url>`

### Arguments
- **`<url>`** — Clone URL of the upstream repository

## `ref:list`

- **Usage:** `ref:list`

List every reference checkout

## `update`

- **Usage:** `update`

Update dotfiles

## `worktree:branch`

Create a worktree for a new or existing remote branch


- Depends: worktree:fetch

- **Usage:** `worktree:branch [--from <from>] [--name <name>] <branch>`

### Arguments
- **`<branch>`** — Branch to create, or an existing remote branch to check out

### Flags
- **`--from <from>`** — Base branch for new branches (default: remote HEAD)
- **`--name <name>`** — Override the worktree directory name

## `worktree:branches`

- **Usage:** `worktree:branches`

List remote branches

## `worktree:fetch`

- **Usage:** `worktree:fetch`

Fetch all branches from origin

## `worktree:init`

Bootstrap a worktree project (clone a URL, or convert the checkout in the current directory)


- **Usage:** `worktree:init [url]`

### Arguments
- **`[url]`** — Repository to clone; omit to convert the checkout in the current directory

## `worktree:list`

- **Usage:** `worktree:list`

List all worktrees

## `worktree:prune`

- **Usage:** `worktree:prune`

Prune stale worktree references

## `worktree:remove`

Remove a worktree and prune stale references


- **Usage:** `worktree:remove <name>`

### Arguments
- **`<name>`** — Worktree directory name, or the branch name it was created from

## `worktree:review`

Switch the pr/ worktree to a given branch


- Depends: worktree:fetch

- **Usage:** `worktree:review <branch>`

### Arguments
- **`<branch>`** — Branch to check out in the pr/ worktree

## `worktree:status`

- **Usage:** `worktree:status`

Show status of all worktrees (branch, dirty, ahead/behind)

## `worktree:sync`

- Depends: worktree:fetch

- **Usage:** `worktree:sync`

Fetch origin and pull all worktrees
<!-- /mise-tasks -->
