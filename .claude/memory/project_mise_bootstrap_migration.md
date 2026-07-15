---
name: project_mise_bootstrap_migration
description: "Migration of the dotfiles from Homebrew to mise's [bootstrap.*] system — DONE: brew removed, all GUI casks (claude/tailscale-app/font/ghostty/obsidian/steam) on brew-cask; only cmux remains on install-app/DMG, untried"
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

**GUI casks migrated to mise brew-cask: (2026-07-04, mise 2026.7.0).** #10626 +
#10671 extended `brew-cask:`: `app` casks copy via `ditto` (signature-preserving),
`pkg` casks install via `sudo installer -pkg`, `font`/`binary` supported.
- **claude** (`app` cask): DONE + verified. `brew uninstall --cask claude` +
  `mise bootstrap packages apply brew-cask:claude`; Gatekeeper accepted, codesign
  deep-strict OK, matches Anthropic PBC baseline. No sudo needed (/Applications is 775).
- **tailscale-app** (`pkg` cask): DONE + verified. Same flow, but the `sudo installer`
  step needs a TTY — I ran the config change, the user ran the swap in their terminal
  (`brew uninstall --cask tailscale-app && mise ... apply`, sudo prompt inline). No task
  change was needed: `install:mise:system-packages` runs `mise bootstrap packages install`
  with inherited stdio, so sudo prompts fine when `mise run install` has a TTY.
- **JetBrains Mono font** (`font` cask): DONE + verified (2026-07-07, mise 2026.7.2). The
  `invalid font target '/$HOME/Library/Fonts/…'` bug (cask.rs:545) was fixed upstream in
  2026.7.1 (`fix(brew-cask): expand font target paths to handle $HOME`, PR #10788 — confirmed
  by reading the commit in `~/Projects/ref/mise`, whose test case reproduces this exact
  JetBrainsMono path). Migrated: removed `[tools."github:ryanoasis/nerd-fonts"]` from
  `mise/config.toml`, added `"brew-cask:font-jetbrains-mono-nerd-font" = "latest"` to
  `mise/config.macos.toml`. Verified end to end by moving the 96 existing font files aside,
  running `mise bootstrap packages apply brew-cask:font-jetbrains-mono-nerd-font`, and
  diffing filenames against the backup (exact match, empty diff). `mise/hooks/install-fonts`
  stays in the repo as the documented fallback for fonts with no Homebrew cask.

IMPORTANT — `brew list --cask` is NOT the ownership signal: mise stores its cask
receipts in the shared Homebrew Caskroom (`/opt/homebrew/Caskroom/<token>/` with a
`.mise-cask.toml` marker), so `brew list --cask` lists mise-managed casks too. The
authoritative check is `brew info --cask <token>` → "Not installed" (brew disclaims both).
Do NOT re-test casks via `brew:` — it's formula-only and 404s on casks.

**Full Homebrew removal — DONE (2026-07-04, dotfiles-cleanup-only scope).** Deleted
`homebrew/Brewfile` (and the `homebrew/` dir) and retired the `install/brew` + `update/brew`
+ `doctor/brew` tasks; scrubbed brew from CLAUDE.md, README.md, and DESIGN.md (layout table,
per-machine layering table, and the install/update/doctor task-flow diagrams), then
regenerated `.github/TASKS.md`. Dropped `HOMEBREW_BUNDLE_FILE` from `shell/env.sh` and the
stale `/homebrew/*.lock` gitignore (now `/homebrew/` — catch-all, nothing there is ours).
Deliberately KEPT `/opt/homebrew` as mise's bottle prefix and did NOT uninstall the brew CLI —
it sits unused at zero risk, and `env.sh`/`path.sh` still export the prefix (mise pours
bottles there and creates the prefix itself; the brew CLI isn't needed for `brew:` or
`brew-cask:`). `brew-cask:claude`, `brew-cask:tailscale-app`, and
`brew-cask:font-jetbrains-mono-nerd-font` are declared, all mise-managed — the cask
migration is fully complete, no blocked items remain.

**obsidian/steam/ghostty → brew-cask attempted and REVERTED (2026-07-07, mise 2026.7.2).**
Looked like the natural next step after claude/tailscale-app/font succeeded, so all three
(plus the `install/obsidian` gate, which keyed on `mise ls "github:obsidianmd/obsidian-releases"`
and would've broken once obsidian left `[tools]`) were migrated in one pass. `mise bootstrap
packages install` ran clean with no errors — but `spctl -a -vv` (the actual Gatekeeper
assessment, not just `codesign --verify`) rejected all three fresh `/Applications` copies with
"bundle format is ambiguous (could be app or framework)". Root cause, confirmed by diffing
`Contents/Frameworks/*.framework` between the old (`install-app`/`ditto`, working) and new
(`brew-cask`, broken) copies: the old copy preserves the framework's versioned-symlink layout
(`Electron Framework -> Versions/Current/Electron Framework`, etc.); brew-cask's copy
dereferences those symlinks into real duplicated files, corrupting the bundle shape. This is
the exact "dereferences internal symlinks, breaks the code-signature seal" failure mode the
pre-2026.7.0 comments described for claude — except claude's `Electron Framework.framework`
(same shape) installs fine via brew-cask today, so this isn't a blanket regression, it's
specific to how these three casks (obsidian, steam, ghostty) get fetched/copied — maybe DMG-
sourced-artifact vs whatever claude's cask uses. Unresolved; not worth digging further until
mise ships another cask-handling fix. Fully reverted: config/doc edits rolled back to HEAD,
the three broken `/Applications` copies deleted, the three working `~/Applications` copies
(install-app-installed) reconfirmed Gatekeeper-accepted. **Next attempt: migrate ONE app at a
time and verify with `spctl -a -vv` before touching the next one** — don't batch, since
brew-cask's cask-by-cask reliability isn't uniform even within the same mise version. Watch
mise release notes for further cask-copy fixes before retrying.

**Checked mise 2026.7.3 (2026-07-08) — does NOT fix the obsidian/steam/ghostty blocker.**
That release's two brew-cask changes, `feat(brew): run cask lifecycle hooks` (#10837) and
`fix(brew): support pkg-created cask binaries` (#10841), looked promising but verified by
diffing `src/system/packages/brew/cask.rs` in `~/Projects/ref/mise` between v2026.7.2 and
v2026.7.3: `install_app()` (the function that `ditto`s the `.app` bundle into place) is
byte-for-byte unchanged — still a plain `ditto from to` with no symlink-preserving flag.
#10837 only adds preflight/postflight Ruby lifecycle-hook execution; #10841 only changes
binary-artifact lookup after `pkg` installs. Neither touches app-bundle copying, so the
framework-symlink-dereferencing bug is still there.

**Root cause was misdiagnosed, actual fix landed in mise 2026.7.6 (2026-07-14) — ghostty
RE-MIGRATED to brew-cask successfully.** The 2026.7.3 investigation diffed the wrong
function: `install_app()`'s `ditto` calls were never the problem (`ditto` preserves
symlinks natively). The real corruption happened one step earlier, in `file::un_dmg()`
(`src/file.rs`) — mounting the DMG then copying its contents out via the generic
`copy_dir_all`, which dereferences symlinks into real files. That's what mangled
`Sparkle.framework`'s versioned-symlink layout (`Versions/Current -> B`, etc.) before
`install_app` ever ran. `fix(bootstrap): preserve symlinks when extracting dmgs` (#10949,
mise 2026.7.6) replaced that call with a new `copy_dir_all_preserve_symlinks` — confirmed
by reading `src/file.rs`'s diff in `~/Projects/ref/mise` between v2026.7.5 and v2026.7.6.
This also explains why claude's cask always worked: claude's Homebrew cask source is a
`.zip` (confirmed via `gh api repos/Homebrew/homebrew-cask/contents/Casks/c/claude.rb`),
so it never touches `un_dmg` — it isn't a blanket brew-cask regression, it's specific to
DMG-sourced casks. Migrated ghostty alone first per [[feedback-migrate-one-app-at-a-time]]:
added `"brew-cask:ghostty" = "latest"` to `mise/config.macos.toml`, ran `mise bootstrap
packages apply brew-cask:ghostty`, verified `spctl -a -vv` → accepted, diffed symlinks +
file count against the old `~/Applications/Ghostty.app` (install-app copy) — identical (7
symlinks, 771 files each). Removed `[tools."http:ghostty"]` from `mise/config.toml` and
deleted the stale `~/Applications/Ghostty.app`.

**obsidian + steam migrated same day (2026-07-14), same verified process, one at a time.**
Both are per-machine (`mise/config.caladan.toml`), unlike global ghostty, so they moved into
that file's `[bootstrap.packages]` as `"brew-cask:obsidian"` / `"brew-cask:steam"` instead of
`config.macos.toml`. obsidian: replaced `[tools."github:obsidianmd/obsidian-releases"]`;
also had to fix `.config/mise/tasks/install/obsidian`'s gate, which keyed on
`mise ls "github:obsidianmd/obsidian-releases"` (that tool ID no longer exists) — now checks
`mise bootstrap packages status --json | jq -e '.["brew-cask"].packages[]? | select(.package
== "obsidian")'`, same "declared regardless of install state" semantic, re-tested via
`mise run install:obsidian`. steam: replaced `[tools."http:steam"]`, no task referenced it.
Both verified `spctl -a -vv` → accepted, symlinks/file-count identical to their old
install-app copies (obsidian 14 symlinks/623 files, steam 6 symlinks/113 files), stale
`~/Applications/*.app` copies deleted. **Full migration is done** — every GUI cask
(claude, tailscale-app, font, ghostty, obsidian, steam) is now on `brew-cask:`. Only `cmux`
(`mise/config.toml`, global) remains on the `install-app`/DMG pattern — untouched so far,
same migration should apply if/when it's tried.

Repo conventions: in ~/.config commit directly to main ([[dotfiles-commit-to-main]]).
