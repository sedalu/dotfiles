---
name: macos-defaults-diff
description: Capture before/after snapshots of ALL macOS defaults, diff them to discover what changed after making changes in System Settings or any app, and interactively track meaningful changes into the dotfiles settings files. Use this skill whenever the user wants to capture, track, record, or save macOS system preference changes, settings changes, or defaults changes to their dotfiles. Also trigger when the user wants to snapshot their macOS state before making changes, or when they say things like "capture settings changes", "snapshot defaults", "track what I just changed in System Settings", or "add this to my dotfiles".
---

## Context

The dotfiles have two macOS settings files:
- `~/.config/macos/settings.sh` — global defaults, organized by section (used on all machines)
- `~/.config/macos/settings.caladan.sh` — machine-specific overrides for this machine

The `defaults read` command (no arguments) dumps all user defaults for all domains at once in a plist-like text format. Diffing two such snapshots shows exactly what changed — including system settings AND app settings.

## Workflow

Follow these steps in sequence. The key interaction point is pausing after the before snapshot so the user can actually make their changes before you capture the after snapshot.

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

This strips obvious noise (timestamps, window positions/sizes, UUIDs, date strings, large floats that look like unix timestamps) and outputs only the meaningful changed lines. Lines prefixed with `<` are the old/before value; `>` are the new/after value.

If the output is empty, tell the user no meaningful defaults changes were detected.

### Step 4: Analysis Pass

The `defaults read` output format groups keys under domain blocks:
```
    "com.apple.dock" =     {
        autohide = 1;
        "tilesize" = 48;
    };
```

The filtered diff only shows changed lines without their domain context. Reconstruct context by running:
```bash
diff <BEFORE> <AFTER>
```
and scanning the surrounding context lines to find which `"domain" = {` block each changed key belongs to. The domain is always the nearest preceding line that matches `"..." =     {`.

**For each changed key, determine:**
- **Domain** — e.g., `com.apple.dock`
- **Key name** — strip surrounding quotes if present
- **Change type**: `ADDED` (only in after), `CHANGED` (different value in before vs after), `DELETED` (only in before)
- **Before/after values**

**Group by domain and present a clean summary:**

```
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

### Step 5: Track / Skip Prompts

For each domain's changes, ask the user to choose one of:
1. **Track globally** → add to `~/.config/macos/settings.sh`
2. **Track as machine-specific** → add to `~/.config/macos/settings.caladan.sh`
3. **Skip** → don't record

Batch the prompt per domain to avoid asking one-by-one when a domain has multiple related changes. Example: "For `com.apple.dock` (tilesize + autohide-delay) — track globally, machine-specific, or skip?"

If the user wants to track some keys from a domain but not others, handle them individually.

### Step 6: Write Confirmed Changes

For each confirmed change:

**1. Get the type:**
```bash
defaults read-type <domain> <key>
```
Map the output to the `defaults write` flag:
- `Type is string` → `-string`
- `Type is boolean` → `-bool`
- `Type is integer` → `-int`
- `Type is float` → `-float`
- `Type is array` or `Type is dictionary` → record as a comment only (arrays/dicts can't be cleanly expressed as a single `defaults write`)

**2. Format the command:**

For changed/added values:
```bash
defaults write <domain> <key> -<type> <value>
```

For deleted keys (reset to system default):
```bash
defaults delete <domain> <key>
```

**3. Add a one-line comment** above the command explaining what the setting does, if it can be inferred from the key name or domain. Use the same style as the existing settings files. If you're unsure, omit the comment rather than guess.

**4. Insert into the target settings file:**

- Find the section whose header best matches the domain's app (e.g., `# --- Dock ---` for `com.apple.dock`, `# --- Finder ---` for `com.apple.finder`)
- Append the new entry at the end of that section, before the next section header
- If no matching section exists, append at the bottom of the file under `# --- Captured ---` (create it if needed)

**Example entry to append:**
```bash
# Dock tile size in pixels.
defaults write com.apple.dock tilesize -int 36
```

**After writing all changes**, summarize what was added to which file so the user can review the diff before committing.
