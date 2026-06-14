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
- GUI casks obsidian + steam → mise `[tools]` (2026-06-13), retiring
  `homebrew/Brewfile.caladan`. They ship a notarized `.app` in a vendor DMG, so
  they install via the `http:`/`github:` backend + the `install-app` hook (mount
  the DMG, `ditto` the `.app` to ~/Applications) — which bypasses `brew-cask:`
  entirely. obsidian = `github:obsidianmd/obsidian-releases` `version="latest"` +
  `asset_pattern="*.dmg"`; steam = `http:` static `steam.dmg`. Validated end to
  end: github→dmg→install-app yields a Gatekeeper-accepted, notarized bundle.
  Hardened `install-app` in passing: staged `ditto` + atomic-swap replace (was
  `cp -R`, which NESTED foo.app/foo.app on every upgrade — obsidian is `latest`,
  so it would have bitten) + quarantine strip + `Contents/` verify. One-time
  per-machine transition (manual, NOT committed): `brew uninstall --cask obsidian
  steam` (clears the old /Applications copies) then `mise install`.
- Go env (GOPATH/GOMODCACHE/GOCACHE) → `[dotfiles]` template (2026-06-13).
  `go/env.tmpl` renders `~/.config/go/env` with XDG paths; deleted the imperative
  `install:go`/`doctor:go` tasks + `lib/dotfiles/go.sh`. `go` reads the file
  natively in every context (not just mise-activated shells, which a mise `[env]`
  block would miss). `template` (not `symlink`) so a stray `go env -w` can't write
  back into the repo. `.gitignore`: `/go/*` + `!/go/env.tmpl` (track the template,
  ignore the rendered file).
- Cleanup (2026-06-13): folded single-consumer `lib/dotfiles/obsidian.sh` into
  `install/obsidian` — its gate now keys off `mise ls <tool>` (empty = not
  configured for this machine) instead of grepping the Brewfile. Fixed the stale
  `brew/Brewfile` → `homebrew/Brewfile` fallbacks (6b3f8d1 left them) in
  `install/obsidian` + `doctor/brew`.

**Blocked — only claude + tailscale-app stay in homebrew/Brewfile:**
mise has two brew prefixes in `[bootstrap.packages]`: `brew:` (formulae, formula
API) and `brew-cask:` (casks, cask API). On 2026.6.6 `brew-cask:` handles only
CLI-ish casks: `app` casks install but mise mangles nested Electron frameworks →
Gatekeeper "App is damaged" (claude); `pkg` / `binary` / `font` artifacts
hard-error "unsupported artifact type" (tailscale-app is `pkg`; nerd-font casks
are `font`). So claude + tailscale-app stay on brew; the `brew` CLI, Brewfile,
and brew tasks are kept. Full brew removal is gated on the tailscale `.pkg`
(would need an `install-pkg` hook). Do NOT re-test casks via `brew:` — it's
formula-only and 404s on every cask; casks need the `brew-cask:` prefix.
GUI apps that ship a plain notarized `.app` in a DMG don't need brew at all —
use `http:`/`github:` + `install-app` (see the obsidian/steam Done bullet).

**Future stages (not started):** none — the declared migration backlog is clear.
The [[feedback_macos_defaults_session]] snapshot/diff workflow remains for
discovering new defaults to add (whether as a scalar pref or a reset-catalog
entry).

Repo conventions: in ~/.config commit directly to main ([[dotfiles-commit-to-main]]).
