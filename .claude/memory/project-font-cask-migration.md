---
name: project-font-cask-migration
description: BLOCKED — JetBrains Mono Nerd Font can't move to brew-cask; mise 2026.7.0's font installer is broken ("invalid font target")
metadata:
  node_type: memory
  type: project
  originSessionId: 44656906-da54-4996-b922-f164e18eec21
---

Migrate the one font in the dotfiles — JetBrains Mono Nerd Font —
off the `github:ryanoasis/nerd-fonts` tool + `install-fonts` hook and onto mise's brew-cask installer.
PR #10671 (font-artifact support) shipped in mise **2026.7.0**,
but the font installer in that release is **broken**, so the migration is blocked.

Current entry stays put (`mise/config.toml`, ~line 188):

```toml
[tools."github:ryanoasis/nerd-fonts"]
version = "latest"
asset_pattern = "JetBrainsMono.tar.xz"
postinstall = "$DOTFILES_DIR/mise/hooks/install-fonts"
```

**Why blocked (verified 2026-07-02 on mise 2026.7.0):**
`mise bootstrap packages apply brew-cask:font-jetbrains-mono-nerd-font` fails with
`brew-cask: invalid font target '/$HOME/Library/Fonts/<file>.ttf'` (cask.rs:545) for every font file.
The cask API JSON is clean (`["<file>.ttf"]`, no target), and mise's own `HOME` resolves correctly,
so mise is somehow assigning a literal `/$HOME/Library/Fonts/…` string as the font target and then rejecting it as absolute.
Not a config error (the token is valid — `status` lists it) and not the sandbox (fails outside it).
No upstream issue existed as of 2026-07-02 — worth filing.

**How to apply (once a fixed mise ships):**
re-test `mise bootstrap packages apply --dry-run brew-cask:font-jetbrains-mono-nerd-font` first;
the token and the `[bootstrap.packages]` mechanism are already confirmed correct.
Then declare `"brew-cask:font-jetbrains-mono-nerd-font" = "latest"` in `mise/config.macos.toml` (macOS-only),
remove the `github:` tool entry from `config.toml`,
and keep `mise/hooks/install-fonts` (still documented as the route for non-cask fonts).
The brew-cask installer links fonts into `~/Library/Fonts` — same destination the hook uses.
Related: [[project_mise_bootstrap_migration]], [[feedback-verify-tool-source-before-config]].
