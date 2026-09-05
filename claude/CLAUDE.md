# Personal Claude Notes

## Workflow Orchestration

### 1. Plan Mode Default

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately – don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy

- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### 3. Verification Before Done

- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness
- Give a high-level summary of what changed at each step, not only at the end
- Close out with a short review: what landed, what surprised you, what is still open

### 4. Demand Elegance (Balanced)

- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes – don't over-engineer
- Challenge your own work before presenting it

### 5. Autonomous Bug Fixing

- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests – then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

## Engineering Standards

Cross-project conventions live in `$DOTFILES_DIR/docs/dev-standards/`
(`~/.config/docs/dev-standards/`).
They apply to every project, and `README.md` there is the index:
it carries the short version and a table per group —
foundations, practices, languages, and the situational files —
each pointing to one file per topic.

Read the file for the topic at hand before setting up a new repo,
or before changing how an existing one is laid out, linted, configured, tested, or deployed.
Load only that file; the set is split so it never has to be in context all at once.

## Authoring Style: Semantic Line Breaks

When writing or editing prose and comments,
break lines at semantic boundaries — one clause or sentence per line —
rather than greedy-wrapping to a fixed column width.
This applies to Markdown prose and to comments in every file type (shell, TOML, pkl, YAML, …).

- Break after sentences and at major clause boundaries
  (before coordinating / subordinating conjunctions, after colons and semicolons).
- Do not hard-wrap at a column count;
  let a line run as long as its one semantic unit requires.
- One idea per line keeps future edits to single-line changes and diffs clean.
- If a project clearly uses fixed-width wrapping, match that instead.

Before finishing any prose or comment,
re-read it and confirm each line ends at a clause/sentence boundary, not a wrap point.
See <https://sembr.org>.

## Reference Checkouts

`~/Projects/ref/` holds upstream git checkouts for source browsing and research.
Use these instead of fetching from the internet when possible.
Pull when a repo looks stale or when asked.
Agents may clone new repos here when a reference checkout would be useful.
See `~/Projects/ref/CLAUDE.md` for the full inventory.

## Shared Dotfiles & Tasks

Bare-worktree setup at `$DOTFILES_DIR` (`~/.config`) enables parallel branch management
and provides mise tasks for both worktree operations and dotfiles maintenance.

**Common daily-use tasks** (global — run from anywhere):

- `worktree:branch [branch-name]` — Create a worktree for development on a new or existing branch
- `worktree:status` — Monitor all worktrees for dirty state and ahead/behind remote
- `worktree:sync [branch]` — Keep worktree in sync with remote
- `worktree:list` — View all active worktrees and branches

**Bootstrap & maintenance tasks** (scoped to the dotfiles tree — `cd $DOTFILES_DIR` first):

- `install` — Full installation (one-time)
- `update` — Update tools and configurations
- `doctor` — Health check

See `$DOTFILES_DIR/docs/TASKS.md` (`~/.config/docs/TASKS.md`) for the complete task reference,
and `$DOTFILES_DIR/docs/DESIGN.md` for the bare-repo layout, worktree workflows, and environment variables.
