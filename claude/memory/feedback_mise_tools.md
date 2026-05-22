---
name: Use mise CLI to manage tools, never hand-edit config.toml tool entries
description: Always use `mise use -g` to add/remove tools instead of editing mise/config.toml directly. Hand-editing TOML caused a bug where tools were silently nested under a sub-table. Keep tools sorted.
type: feedback
---

Never hand-edit `mise/config.toml` to add or remove tools. Use the CLI instead.

**Why:** I added tool entries by editing the TOML file directly and placed them after a `[tools.helix]` sub-table header. In TOML, bare key-value pairs after a sub-table header belong to that sub-table — so 22 tools were silently parsed as properties of `tools.helix` instead of top-level `[tools]` entries. They appeared installed (from prior state) but had no config source, causing shim errors. I also left tools in random insertion order instead of maintaining the sorted convention.

**How to apply:**

1. **Adding a simple tool globally:** `mise use -g <tool>@latest` (e.g., `mise use -g claude@latest`)
2. **Adding a tool with options** (postinstall hooks, asset patterns, platform overrides): Use `mise use -g` first to add the base entry, then edit the config to add the extra options to the generated section. This way the tool entry is correctly placed by mise.
3. **Removing a tool:** `mise use -g --remove <tool>`
4. **If you must hand-edit:** Understand TOML table scoping — bare keys after `[tools.foo]` belong to `tools.foo`, not `[tools]`. Place simple `key = "value"` entries BEFORE any sub-table headers, or use explicit inline tables.
5. **Keep tools sorted:** The `[tools]` section is ordered: prefixed tools grouped by backend (`aqua:`, `github:`, `go:`, `http:`, `npm:`) alphabetically, then bare-name tools alphabetically. Sub-table `[tools.xxx]` entries follow the same sort order after the inline entries. After using `mise use -g`, verify the new entry landed in the right sorted position — re-sort if needed.
6. **Verification:** After any change, run `mise ls` and confirm every tool shows its config source file.
