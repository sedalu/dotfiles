---
name: mise-project-config-shadowed-in-dotfiles
description: In ~/.config, mise/config.toml outranks .config/mise/config.toml, so project tool pins do not take effect locally
metadata:
  type: project
---

`mise/config.toml` is one of mise's own *project* config filenames,
not only the global config path.
In the dotfiles repo — whose root is `$XDG_CONFIG_HOME` —
it is therefore loaded as a project config too,
and it outranks `.config/mise/config.toml`.

Any tool declared in both resolves to the global entry (`latest`),
so the project's pins do not apply locally.
Settings and `[env]` from the project config are unaffected; only tool versions are.

**Why:** it defeats the project/system scope separation the repo is built around,
and makes local tool versions differ from CI.

**How to apply:** ignore the payload config when the project's pins must win —
`MISE_IGNORED_CONFIG_PATHS="$PWD/mise"`.
The CI workflow does this, and it is also how `mise lock` was made to resolve the full toolchain.
Open as of 2026-09-04: the wanted end state is that `mise/config.toml` still serves as the
*global* config while in the repo, just not at project scope.
Do not "fix" it by disabling the global config.

Related: [[feedback-xdg-classify-by-data]], [[mise-vars-not-in-tool-postinstall]].
