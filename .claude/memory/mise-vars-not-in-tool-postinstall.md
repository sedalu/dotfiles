---
name: mise-vars-not-in-tool-postinstall
description: "mise [vars] don't render inside [tools] postinstall strings; using them there breaks every introspection command"
metadata: 
  node_type: memory
  type: project
  originSessionId: c3991c76-0a01-4796-8ff2-4cf3495c5f33
---

In mise 2026.6.6, a `{{ vars.x }}` reference renders in task `run` strings
but NOT inside `[tools].postinstall` (or other tool-option) strings.
Putting `{{ vars.hooks }}` in a tool's `postinstall` made
`mise run`, `mise tasks`, `mise config`, and `mise vars` all hard-fail
with `Variable vars.hooks not found in context` during the eager whole-config render —
even though the var DID resolve at actual `mise install` time in an isolated test.

**Why:** the eager config render that `run`/`tasks`/`config`/`vars` perform
builds its Tera context without the `[vars]` table, so any tool-option template referencing it throws.
This makes it a trap: it looks like it works (install succeeds) but breaks the entire task system.

**How to apply:** don't try to DRY the repeated `$DOTFILES_DIR/mise/hooks/...`
postinstall prefixes in `mise/config.toml` with `[vars]` —
keep the literal `$DOTFILES_DIR/...` (shell-expanded at hook runtime).
Revisit only if a newer mise version fixes vars-in-tool-options.
Relates to [[project_mise_bootstrap_migration]] and [[feedback-config-authoring-style]].
