---
name: project_mise_bootstrap_migration
description: "Staged migration of the dotfiles from Homebrew to mise's [bootstrap.*] system; what's done, what's blocked, what's next"
metadata: 
  node_type: memory
  type: project
  originSessionId: 6717805a-7b83-4289-af3b-cb295157b81e
---

Ongoing (as of 2026-06-13): incrementally moving the dotfiles off Homebrew onto
mise's experimental `mise bootstrap` / `[bootstrap.*]` system (mise 2026.6.6).
Deliberately staged — "it's early days, we'll hit rough edges and evolve as it
matures." Expect breaking churn between mise releases (the `[system.packages]`
→ `[bootstrap.packages]` rename already broke us once).

**Done & committed:**
- System formulae + the `mas` CLI → `[bootstrap.packages]` (mise pours bottles
  into /opt/homebrew, no `brew` needed). macOS-only packages in
  `mise/config.macos.toml`, machine-global in `mise/config.toml`.
- Native per-OS / per-machine layering via `mise/miserc.toml`: `auto_env = true`
  loads `config.<os>.toml` / `config.<os>-<arch>.toml`; `env = [DOTFILES_MACHINE]`
  loads `config.<machine>.toml` (e.g. `config.caladan.toml`). All
  `[bootstrap.packages]` tables union across loaded files — the native
  replacement for the old `Brewfile.<machine>` sidecars.
- Symlinks → mise `[dotfiles]` (commit 9fe13a5, 2026-06-13). Replaced the
  hand-rolled `lib/dotfiles/symlinks.sh` array + `symlinks.caladan.sh` sidecar
  (both deleted) with `[dotfiles]` tables in `config.toml` (base) and
  `config.caladan.toml` (per-machine, unions via MISE_ENV). `install:symlinks`
  now backs up conflicting non-symlink targets to `.bak` (ACL-stripping a
  pristine `~/Downloads` first) then `mise dotfiles apply --force`;
  `doctor:symlinks` gates on `mise dotfiles status --missing`. `~/Downloads →
  iCloud` rides along as a non-repo-sourced symlink entry.
- macOS scalar prefs → `[bootstrap.macos.defaults]` (hybrid, 2026-06-13,
  committed 677395a). Probed mise 2026.6.6: macos-defaults handles
  scalar writes only (string/int/bool/float; `0.0`→`-float`), with `apply` /
  `status --missing` + MISE_ENV layering — but silently DROPS arrays/dicts, has
  NO delete (every value is a write), and NO killall. So only the ~25 scalar
  `defaults write` prefs moved to `[bootstrap.macos.defaults]` (base in
  config.toml, caladan in config.caladan.toml). The `defaults delete`
  reset-catalog + `killall_targets` stay in `macos/settings.sh`; manual-only
  settings (Tips/Mail/Spotlight) → new `macos/manual.md`; `settings.caladan.sh`
  deleted. `install:macos` = `mise bootstrap macos-defaults apply` + sourced
  deletes, restarting only changed apps (write-domains from `status` pre-apply,
  delete-domains from before/after snapshot — no jq). `doctor:macos` gates on
  `status --missing` then checks each catalog key absent. `catalog:macos` seeds
  `_tracked` from `mise ... status` so it never re-adds a `defaults delete` for a
  written key. `lib/dotfiles/macos.sh` simplified to delete-only parsing. NOTE:
  removed two global deletes (NSTableViewDefaultSizeMode, FlashDateSeparators)
  that conflicted with caladan writes — a reset-catalog must never delete a key
  some machine explicitly writes.
- Login shell → `[bootstrap.user].login_shell` (2026-06-13, applied; committed
  9859db0). New capability, not a migration: nothing managed the
  login shell before. `config.macos.toml` declares `login_shell =
  "/opt/homebrew/bin/zsh"` (Homebrew zsh, replacing system `/bin/zsh`; macOS-only
  since the path is arch-specific, auto-loaded on every macOS machine). New tasks
  `install:login-shell` (wraps `mise bootstrap user apply --yes`) and
  `doctor:login-shell` (gates on `status --missing`), both auto-discovered by the
  `[!_]*` glob and skipping when status is empty (non-macOS). `apply` registers the
  shell in `/etc/shells` (one-time `sudo` append, needs a TTY) then `chsh`'s the
  account — converges to a no-op after. Install+doctor only (no update task), like
  symlinks/ssh.
- `ssh/config` stays a plain `mode = "symlink"` (no template stage needed,
  2026-06-13). The once-considered `template` conversion was only motivated by a
  colima `Include` line colima had appended to `~/.ssh/config` (which symlinks
  through to the tracked `ssh/config`). Fixed at the source — colima's `sshConfig`
  disabled via `colima start --ssh-config=false` in the family-office project's
  `.config/pitchfork.toml` (the only place colima starts), stray line reverted.
  Nothing machine-specific remains in `ssh/config`, so a symlink is correct.
  colima's state dir at `~/.config/colima` is just XDG (`XDG_CONFIG_HOME`);
  gitignored (`/colima/`) runtime state, never committed.

**Blocked — GUI casks stay in homebrew/Brewfile + Brewfile.caladan:**
mise 2026.6.6 cask support is unusable for our apps. pkg-type (tailscale-app)
and binary-type (obsidian) artifacts hard-error "unsupported". app-type
(claude, steam) install but mise mangles nested Electron frameworks → bundle
fails Gatekeeper ("App is damaged"); brew's install of the same version is
notarization-valid. Do NOT re-try cask migration until mise cask support
matures. The `brew` CLI, Brewfile, and brew tasks are intentionally kept.

**Future stages (not started):** none — the declared migration backlog is clear.
The [[feedback_macos_defaults_session]] snapshot/diff workflow remains for
discovering new defaults to add (whether as a scalar pref or a reset-catalog
entry).

Repo conventions: in ~/.config commit directly to main ([[dotfiles-commit-to-main]]).
