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

### Protected branches

The rules above are local discipline, and a hook binds only the checkout it is installed in.
The forge has to enforce the same thing on its own side.

Where a repo takes its changes through pull requests,
its default branch carries a protection rule:

| Setting                           | Value                 | Why                                                             |
| --------------------------------- | --------------------- | --------------------------------------------------------------- |
| Direct push                       | blocked, no allowlist | Every change arrives as a pull request                          |
| Apply to admins                   | on                    | A rule that exempts admins binds nobody on a single-owner forge |
| Required status checks            | on, contexts named    | Nothing else makes a check binding — see below                  |
| Block on outdated branch          | on                    | A check that passed, passed against the tree being merged       |
| Update branch by rebase           | allowed               | A branch blockable for being behind has to be movable           |
| Block on rejected reviews         | on                    | Costs nothing until someone reviews, correct on the day they do |
| Block on official review requests | on                    | Same                                                            |
| Dismiss stale approvals           | on                    | A push invalidates the approval that predates it                |
| Required approvals                | **0**                 | An author cannot approve their own pull request                 |

Everything not listed stays at its default.
Required approvals is the one entry that is off rather than on:
on a solo repo any other value is a deadlock rather than a stricter rule,
and it is the first line to revisit when a repo gains a second person.

#### Naming the check

A context is `<workflow> / <job> (<event>)`,
so the `ci` workflow's `ci` job from [ci.md](ci.md) reports as `ci / ci (pull_request)`.
Contexts are compiled as globs rather than compared as strings,
so a check name containing `*`, `?`, `[`, or `{` will not mean what it reads as.

The toggle and the context list fail in opposite directions,
so neither is a safe default for the other:

| Toggle | Contexts             | Result                                                                |
| ------ | -------------------- | --------------------------------------------------------------------- |
| off    | —                    | Every status advisory; the merge gate returns true before reading any |
| on     | empty                | The worst of whatever posted — and no statuses at all is unmergeable  |
| on     | named, never reports | Pending forever, and pending is not success                           |
| on     | named, reporting     | The rule                                                              |

Enable the toggle only once the workflow it names already runs on the repo.
Row 3 is what a repo with no CI gets, and the pull request page does not explain it.
That same row is why a *renamed* workflow fails closed rather than opening the gate,
which is worth having — in that order.

#### Why the check is the half that matters

Nothing looks wrong while a person is clicking every merge button,
so this is the setting that gets left off.
It stops being invisible the moment something merges unattended.
[dependencies.md](dependencies.md) allows automerge for tooling updates,
and Renovate arms the forge's own "merge when checks succeed" as it opens the pull request —
before any check has reported.
On row 1 there is nothing to wait for, and it merges immediately.

The exception above is the same exception here.
A checkout granted `defaultBranch.allowDirectCommits` commits to its default branch by design,
so protecting that branch on the forge denies the thing the exception permits.
They are two halves of one decision about a repo, not two independent settings.

### Merge method

| Setting                                                | Value |
| ------------------------------------------------------ | ----- |
| Squash                                                 | on    |
| Merge, rebase, rebase-merge, fast-forward-only, manual | off   |
| Delete branch after merge                              | on    |

A pull request lands as exactly one commit on the default branch.

The consequence to know before it looks like a problem:
a squash-merged branch is not an ancestor of the default branch,
so `git branch -d` refuses it as unmerged.
An empty `git diff <branch> <the squash commit>` is the proof that it merged,
and `-D` is then the correct deletion rather than a force.

### Worktree layout

A repo using worktrees is a directory of sibling checkouts:

```text
<repo>/
  main/        # a normal clone, checked out to main, kept clean
  <branch>/    # git worktree add ../<branch>
```

`main/` holds the git directory and is never worked in.
Each branch is a linked worktree beside it, never nested inside it.

A second Claude Code hook enforces this layout.
It denies any command that would take `main/` off the default branch —
a switch, a checkout, a detach, a rename —
and denies edits and commits there on whatever branch it is on.
The hook above stops at checkouts that are *on* the default branch,
so without that second half a `main/` already moved off it is the one place left unguarded.
Returning to the default branch stays allowed, as does the work `main/` exists for:
fetching, pruning, and adding worktrees.
`worktree:branch` cuts the sibling to work in.

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

`HK=0` bypasses the hooks, as does git's own `--no-verify`.
Bypassing is for a broken hook, not for a failing or a slow check.
A Claude Code hook asks before running either one,
so an agent cannot decide on its own to stop enforcing the pipeline.

A bypass obliges a repair.
Fix the hook before the next push,
rather than settling into a workflow that routes around it —
a pipeline that is habitually bypassed is enforcing nothing.
