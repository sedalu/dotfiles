# Memory Index

- [feedback_stage_new_files.md](feedback_stage_new_files.md) — Always stage new/untracked files when committing, especially in bare repos
- [feedback_git_add_force.md](feedback_git_add_force.md) — Always use `git add -f` in this bare-repo dotfiles setup
- [feedback_mise_tools.md](feedback_mise_tools.md) — Use `mise use -g` CLI to add/remove tools, never hand-edit TOML tool entries
- [feedback_commit_scope.md](feedback_commit_scope.md) — Only stage files related to the current task when committing
- [feedback_mise_trust.md](feedback_mise_trust.md) — Run `mise trust` after creating a worktree, clone, or entering a new dir with mise config
- [feedback_no_speculation.md](feedback_no_speculation.md) — Never speculate — always investigate with tools before answering
- [feedback_subagent_types.md](feedback_subagent_types.md) — Use correct subagent type: Explore=local files only, general-purpose=web/external requests
- [feedback_macos_defaults_session.md](feedback_macos_defaults_session.md) — macOS defaults snapshots: use `defaults read > file` + diff, not per-domain dirs
- [reference_renovate_mise_lock.md](reference_renovate_mise_lock.md) — Renovate bumps mise versions but won't regenerate mise.lock — needs a CI step
- [project_macos_defaults_todos.md](project_macos_defaults_todos.md) — Future work: automate macos-defaults catalog sync and update tracking
