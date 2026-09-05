---
name: mise-project-config-shadowed-in-dotfiles
description: "In ~/.config, mise/config.toml outranks .config/mise/config.toml; fixed via override_config_filenames in .config/miserc.toml"
metadata: 
  node_type: memory
  type: project
  originSessionId: 09972d4a-b32d-4b5f-9a53-3304218b94c8
  modified: 2026-09-05T03:31:35.292Z
---

`mise/config.toml` is one of mise's own *project* config filenames,
not only the global config path.
In the dotfiles repo — whose root is `$XDG_CONFIG_HOME` —
it is therefore loaded as a project config too.
mise's local filename list is later-wins,
and every `mise/*` entry ranks above every `.config/mise/*` one,
so the workstation toolchain shadowed the project's pins
and only CI ran the versions actually pinned.

Fixed 2026-09-04 by `.config/miserc.toml`,
an early-init file mise finds by walking up from the cwd,
setting `override_config_filenames` to mise's default list minus the three `mise/*` entries.
The global load path is separate from that list,
so `mise/config.toml` still loads as the global config with its platform and machine layers.
`doctor:pins` asserts every pin resolves from `.config/mise/config.toml` and fails if shadowing returns.

**Why:** `MISE_IGNORED_CONFIG_PATHS` — the earlier workaround — also drops the file as the
*global* config, which strips the workstation toolchain inside the repo.
A root `mise.toml` beats `mise/config.toml` but not `mise/config.macos.toml`,
because mise's environment patterns outrank every base filename.

**How to apply:** the setting replaces mise's filename list rather than filtering it,
so it needs restating if mise adds a filename.
It also does not cover environment patterns, so `mise/config.macos.toml` still loads at project
scope — harmless only while the pipeline's tools stay out of the platform and machine layers.

Related: [[feedback-xdg-classify-by-data]], [[mise-vars-not-in-tool-postinstall]].
