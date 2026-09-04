# Git

## Commits

Conventional commits — `type(scope): description` — enforced by hk's `commit-msg` hook.

Commit a file move on its own, before editing it, so git records a rename.

Never rewrite published history.
Amend, rebase, reset, and force-push are reserved for an explicit instruction;
otherwise new work is a new commit.

## Branching

All work happens on a new branch. Never on the default branch.
A worktree is preferred over switching branches in place, but either satisfies the rule.

An exception is declared per checkout, in local git config:

```sh
git config --local defaultBranch.allowDirectCommits true
```

The key is local, so it never travels with the repo:
one checkout can be the exception while every other checkout of the same repo still branches.
An exception is never inferred from the repo's size, its audience,
or the fact that nobody else commits to it.

Granting an exception is the human's call, and the reasons are theirs.
A checkout that is itself a live installation is one such case —
a tree something reads in place, at a path fixed by whatever consumes it,
which for the same reason sits outside the worktree layout below,
since it cannot move to make room for a `main/` sibling.
It is not the only one.

A Claude Code hook enforces this.
It denies an edit or a commit on the default branch in any checkout that has not set the key,
and reports a default branch that is already dirty when a session starts.

Setting the key is itself denied to an agent, which is handed the command to pass to a person.
An exception the enforced party can grant itself is not an exception.

### Worktree layout

A repo using worktrees is a directory of sibling checkouts:

```text
<repo>/
  main/        # a normal clone, checked out to main, kept clean
  <branch>/    # git worktree add ../<branch>
```

`main/` holds the git directory and is never worked in.
Each branch is a linked worktree beside it, never nested inside it.

This layout is what mise's worktree trust sharing requires.
A config inside a linked worktree inherits the trust of the equivalent path in the main checkout,
so trusting `main/` once covers every branch cut afterward.
A bare repository has no main checkout and shares no trust with its worktrees,
which is why `main/` is a normal clone.
Paranoid trust mode disables the sharing as well,
since a worktree can check out a branch whose config differs.

## Hooks

Hooks are wired through hk, declared in the repo's git config as `hook` entries
that dispatch to `hk run <event> --from-hook`.

Set `HK_MISE = "1"` in the mise config.
It wraps the git hooks with `mise x`,
so a hook runs with the project's tools and environment
even for someone who has not activated mise in their shell.
It is also what puts `.config/mise/bin` on the hook's `PATH`,
so a config wrapper covers a hook run as well as an interactive one.

Split by cost:
`pre-commit` runs formatters and fast linters on staged files,
`pre-push` runs the slow or authoritative checks —
secret scanning, vulnerability scanning, generated-code drift gates.

`pre-commit` fixes but never stages:
set `fix = true` alongside `stage = false` and `fail_on_fix = true`.
A fix lands in the working tree and blocks the commit,
so nothing reaches a commit that was not read and staged by hand.
Auto-fixers change content, not only layout —
they rewrite words, add and drop imports, and edit the module requirements —
and staging that silently commits work nobody reviewed.
Keep `stash = "git"` so fixes are computed against the staged content rather than the dirty tree.

`HK=0` bypasses the hooks.
Bypassing is for a broken hook, not for a failing check.

A bypass obliges a repair.
Fix the hook before the next push,
rather than settling into a workflow that routes around it —
a pipeline that is habitually bypassed is enforcing nothing.
