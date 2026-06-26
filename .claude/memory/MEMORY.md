# Memory Index

- [dotfiles-commit-to-main.md](dotfiles-commit-to-main.md) — in ~/.config, commit directly to main; don't branch first
- [feedback-never-rewrite-commits.md](feedback-never-rewrite-commits.md) — never amend/rebase/reset/force-push unless explicitly told; new work = new commit
- [feedback_macos_defaults_session.md](feedback_macos_defaults_session.md) — macOS defaults snapshots: use `defaults read > file` + diff, not per-domain dirs; project skills live in `<project>/.claude/skills/`
- [project_macos_defaults_todos.md](project_macos_defaults_todos.md) — Future work: automate macos-defaults catalog sync and update tracking
- [project_mise_bootstrap_migration.md](project_mise_bootstrap_migration.md) — staged Homebrew→mise migration: obsidian/steam→[tools], Go→[dotfiles]; only claude+tailscale casks remain on brew (brew-cask: limits)
- [feedback-config-authoring-style.md](feedback-config-authoring-style.md) — no inline TOML tables; semantic line breaks in comments
- [feedback-yaml-always-quote-strings.md](feedback-yaml-always-quote-strings.md) — always double-quote YAML string values; enforced by ryl (linter) + yamlfmt (formatter)
- [mise-vars-not-in-tool-postinstall.md](mise-vars-not-in-tool-postinstall.md) — mise [vars] don't render in [tools] postinstall; breaks every introspection command — don't use them there
- [feedback-xdg-classify-by-data.md](feedback-xdg-classify-by-data.md) — XDG-relocate tool dirs by data class (state→STATE_HOME out of worktree, config→CONFIG_HOME); don't reflexively use CONFIG_HOME
- [feedback-verify-tool-source-before-config.md](feedback-verify-tool-source-before-config.md) — verify a tool's command names/behavior from upstream source in ~/Projects/ref before proposing config; don't recall from memory
- [feedback-confirm-before-implementing.md](feedback-confirm-before-implementing.md) — for non-trivial tradeoffs, present the recommendation and wait for go-ahead before editing files
