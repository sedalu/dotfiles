---
name: macos-defaults-diff
description: Capture before/after snapshots of ALL macOS defaults, diff them to discover what changed after making changes in System Settings or any app, and interactively track meaningful changes into the dotfiles settings files. Use this skill whenever the user wants to capture, track, record, or save macOS system preference changes, settings changes, or defaults changes to their dotfiles. Also trigger when the user wants to snapshot their macOS state before making changes, or when they say things like "capture settings changes", "snapshot defaults", "track what I just changed in System Settings", or "add this to my dotfiles".
---

## Context

The `defaults read` command (no arguments) dumps all user defaults for all domains at once in a plist-like text format.
Diffing two such snapshots shows exactly what changed — including system settings AND app settings.

### Where a captured setting goes

The dotfiles track macOS settings in three layers.
Pick the layer by what *kind* of value it is, not by which file looks closest.

| Layer         | Holds                                                   | Location                                                                                |
| ------------- | ------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Preferences   | Scalar values (string, bool, int, float)                | `[bootstrap.macos.defaults]` in `mise/config.toml`; per-machine in `mise/config.<machine>.toml` |
| Reset-catalog | Keys kept at their macOS default (`defaults delete`)    | `lib/dotfiles/macos-settings.sh`                                                          |
| Manual        | Anything with no `defaults write` form                  | `docs/macos-manual.md`                                                                    |

Applied by `mise run install:macos`, checked by `mise run doctor:macos`.

Two rules that override the obvious guess:

- **`lib/dotfiles/macos-settings.sh` is generated.** `mise run catalog:macos` syncs it from macos-defaults.com.
  Never hand-add a `defaults write` line to it — a capture belongs in `[bootstrap.macos.defaults]` instead.
- **`lib/dotfiles/macos-settings.<machine>.sh` does not exist.**
  Machine-specific values are TOML, in `mise/config.<machine>.toml` (`caladan` on this machine),
  unioned with the base config via `MISE_ENV`.

Arrays, dictionaries, and settings applied by something other than `defaults`
(`launchctl`, a sandboxed app container, a System Settings pane with no backing key)
go in `docs/macos-manual.md` as prose — see the Spotlight and Dock entries there for the house style.

## Workflow

Follow these steps in sequence.
The key interaction point is pausing after the before snapshot
so the user can actually make their changes before you capture the after snapshot.

### Step 1: Before Snapshot

Run:

```bash
macos-snapshot
```

Save the output path. Tell the user the path and ask them to make their changes:

> "Before snapshot captured at `<path>`. Make your changes in System Settings or any app, then let me know when you're done."

**Stop here and wait for the user to confirm they've made their changes.** Do not proceed to the next step.

### Step 2: After Snapshot

Once the user confirms, immediately run:

```bash
macos-snapshot
```

Save this path as `AFTER`.

### Step 3: Filtered Diff

Run:

```bash
macos-snapshot-diff <BEFORE> <AFTER>
```

This strips obvious noise (timestamps, window positions/sizes, UUIDs, date strings, large floats that look like unix timestamps)
and outputs only the meaningful changed lines.
Lines prefixed with `<` are the old/before value; `>` are the new/after value.

If the output is empty, tell the user no meaningful defaults changes were detected.

### Step 4: Analysis Pass

The `defaults read` output format groups keys under domain blocks:

```text
    "com.apple.dock" =     {
        autohide = 1;
        "tilesize" = 48;
    };
```

The filtered diff shows changed lines without their domain context,
and the filter is imperfect — it lets timestamp churn through,
so expect to classify some surviving lines as noise yourself.

Reconstruct context by mapping each changed line back to its enclosing domain.
Get the hunk line numbers, then walk backwards to the nearest domain header:

```bash
diff <BEFORE> <AFTER> | grep -E '^[0-9]'
awk -v n=<LINE> 'NR<=n && /^    "[^"]*" =/ {d=$0} END{print d}' <AFTER>
```

The domain is always the nearest preceding line matching `"..." =     {` at four-space indent.

**For each changed key, determine:**

- **Domain** — e.g., `com.apple.dock`
- **Key name** — strip surrounding quotes if present
- **Change type**: `ADDED` (only in after), `CHANGED` (different value in before vs after), `DELETED` (only in before)
- **Before/after values**

**Group by domain and present a clean summary:**

```text
com.apple.dock
  CHANGED  tilesize          48 → 36
  ADDED    autohide-delay    0.5

com.apple.finder
  CHANGED  NewWindowTarget   PfLo → PfHm
```

If there are more than 10 changes, present one domain at a time.

**Flag as likely noise (suggest skip, but let the user decide):**

- Keys containing `Count`, `Recent`, `Cache`, `Index`, `Sequence`, `Token`, `Nonce`
- Values that are large blobs of encoded data
- `_DKThrottledActivityLast_*` usage timestamps (`Apple Global Domain`, `com.apple.knowledge-agent`)
- `com.apple.xpc.activity2` activity-scheduler timestamps
- `com.apple.dock` `mod-count`, which bumps on any Dock edit
- Per-app window geometry blobs (`*WindowGeometry*`, `*windowFrame*`)

### Step 5: Track / Skip Prompts

For each domain's changes, ask the user to choose one of:

1. **Track globally** → `[bootstrap.macos.defaults]` in `mise/config.toml`
2. **Track as machine-specific** → `[bootstrap.macos.defaults]` in `mise/config.<machine>.toml`
3. **Skip** → don't record

For a non-scalar value there is no global/machine choice to offer — it is document-in-`macos-manual.md` or skip.
Say so rather than presenting the scalar options.

Batch the prompt per domain to avoid asking one-by-one when a domain has multiple related changes.
Example: "For `com.apple.dock` (tilesize + autohide-delay) — track globally, machine-specific, or skip?"

If the user wants to track some keys from a domain but not others, handle them individually.

### Step 6: Write Confirmed Changes

**1. Get the type:**

```bash
defaults read-type <domain> <key>
```

Map the output to a TOML value:

- `Type is string` → quoted string
- `Type is boolean` → `true` / `false`
- `Type is integer` → bare integer
- `Type is float` → decimal with an explicit `.0` if whole
- `Type is array` or `Type is dictionary` → not a preference; document in `docs/macos-manual.md`

**2. Insert into the target config:**

Find the `[bootstrap.macos.defaults."<domain>"]` table in the chosen file,
or add one at the end of the existing `[bootstrap.macos.defaults…]` block if the domain is new.
Quote the domain in the table header (`NSGlobalDomain` is the one bare exception, matching the existing entries).
Quote the key too when it contains a dot.

```toml
[bootstrap.macos.defaults."com.apple.dock"]
# Icon size of Dock items, in pixels.
# https://macos-defaults.com/dock/tilesize.html
tilesize = 36
```

Add a one-line comment above the key explaining what the setting does,
plus the macos-defaults.com URL when the key is catalogued there.
If you're unsure what it does, omit the comment rather than guess.
No inline tables; semantic line breaks in comments.

**3. Check the restart target:**

If the domain is new and its app needs a restart to pick the change up,
add a `"domain:App Name"` entry to `killall_targets` in `lib/dotfiles/macos-settings.sh`.
That array is hand-maintained even though the rest of the file is generated.

**4. For manual entries**, append a `###` section under the machine heading in `docs/macos-manual.md`
stating what the setting is, why it can't be automated, and the intended value.

**After writing all changes**, verify with:

```bash
mise run doctor:macos
```

then summarize what was added to which file so the user can review the diff before committing.
