---
name: feedback-verify-tool-source-before-config
description: "Before proposing a tool's keybindings/config, verify command names and behavior from upstream source in ~/Projects/ref — don't recall from memory"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 642c6188-29f6-4619-b2e2-05ef7008e98d
---

When advising on or editing a tool's configuration (keybindings, commands, modes, settings),
verify the actual command names, default bindings, and runtime behavior from the upstream source first —
clone it into `~/Projects/ref/` if not already there (see [[dotfiles-commit-to-main]] context for the dotfiles repo).

**Why:** The user caught me speculating about Helix mode names and fabricating command behavior
(claimed `delete_selection` could enter insert mode — it always exits to normal via `exit_select_mode`).
Confidently wrong details erode trust and waste the user's review cycles.

**How to apply:** Read the real keymap/command source before proposing bindings.
Cite file:line when stating a default or behavior.
Flag genuine conflicts found in the source (e.g. Helix normal-mode `C-a`=increment) rather than glossing over them.
Also account for the OS layer (macOS owns `Ctrl+Arrow` for Mission Control; Cmd can't reach terminal apps).
