# Tooling

mise is the only tool installed by hand.
Every other tool is a mise-pinned project dependency — never brew, never a system package, never a global install.
A fresh clone is bootstrapped by `mise install` and nothing else.

## Choosing a tool

A tool must install through mise
(the registry, or the `github:`, `aqua:`, `go:`, or another language backend).

It should also compile to a native binary.
A tool that needs a Python, Node.js, or Java runtime clears a very high bar:
it has to deliver value no native tool comes close to,
with no substitute that is merely good enough.
Writing one counts as a substitute —
a self-authored native tool is preferable to adopting a runtime dependency.

The native-binary preference is what decides most tool questions before they are argued:
it selects rumdl over markdownlint, ryl over yamllint, and biome over prettier.

## Pinning

Every version resolves to exactly one release, on every machine, until someone moves it.
Never `latest`, never a floating tag.
What holds that exact version depends on whether the manager keeps a lockfile.

### Where there is a lockfile

mise, and any manager like it.

- **Pin the exact patch in the config, not a `major.minor` prefix.**
  Never `latest`.
  A partial pin reads like a policy —
  which upgrades are acceptable without anyone making a decision —
  but the updater reads it as a range,
  and clamps the tool inside it forever.
  Renovate's mise manager, finding a partial selector with a lockfile beside it,
  marks the dependency `isLockfileOnly`
  and derives `allowedVersions` from the pin
  (`lib/modules/manager/mise/extract.ts`, `getSelectorConfig`).
  `hk = "1.58"` then collects patch bumps inside 1.58,
  and is never offered 1.59 or 2.0.
  Neither `isLockfileOnly` nor the derived clamp is a configurable option,
  so no rule in the Renovate config can lift it.
  The freeze is silent in the worst way:
  the lockfile keeps moving,
  so every tool reports the newest patch of a minor that stopped being current long ago.
  `hk = "2.0.1"` fails the partial-selector test,
  and updates like anything else.
  State the policy once in the Renovate config,
  where it applies to every tool — see [dependencies.md](dependencies.md).
- **The lockfile still owns what installs.**
  It records the version that actually resolves,
  so it is committed and moved together with the pin,
  never on its own.
  A config entry with no lockfile beside it is not a pin at all:
  it resolves independently on every machine, and two workstations silently disagree.
  Set `lockfile = true` so mise creates and maintains `mise.lock`,
  rather than only updating one that already exists.
  This is why [dependencies.md](dependencies.md) requires an update to move both —
  a change that moves the config pin and leaves the lock behind moves nothing that installs.
- Change a version with `mise use <tool>@<version>`, or `mise upgrade` to move it forward.
  Both write the config and the lockfile together.
- A version edited by hand does not take effect —
  mise prefers the locked version over the config until `mise lock` reconciles them.
- Tool entries carrying options use the table form; version-only entries stay inline strings:

  ```toml
  # correct
  [tools.colima]
  version = "0.9.2"
  depends = "lima"

  # wrong
  colima = { version = "0.9.2", depends = "lima" }
  ```

  No formatter enforces this.
  The rule is about mise configs,
  whose `[tools]` entries are heterogeneous:
  a file that mixes `colima = { version = "0.9.2", depends = "lima" }` with plain version strings reads as two conventions for one list,
  and an entry that gains an option has to be rewritten rather than extended.
  Write `[table]` and `[parent.child]` sections instead.

  This does not govern TOML generally.
  A file of many homogeneous records — a data file rather than a config —
  is better served by an array of inline tables,
  one record per line,
  which holds a diff to the record that actually changed.
  Choose the form from the shape of the file:
  sections where entries differ from each other,
  inline tables where they repeat.
- A language toolchain is pinned in `[tools]` like every other tool.
  Never resolve it from the language's own manifest:
  a manifest's language-version directive states the minimum version the module requires,
  not the toolchain everyone builds with,
  and the directive that would name a toolchain is optional and routinely absent.
- A tool that parses or type-checks the language it is written in
  is bound to the toolchain it was built against,
  and is rebuilt when that toolchain moves,
  or it reads new source as an older language.
  The test is whether the tool understands the language, not whether it is written in it.
- That rebuild is a `postinstall` on the toolchain's own `[tools]` entry.
  It fires only when the toolchain is installed,
  and runs with the new toolchain already on `PATH`,
  so the tools are built against it.
  Use `mise install --force` so already-installed tools actually rebuild.
  Installing them does not re-enter the hook, so it needs no recursion guard.
- mise `[vars]` do not render inside a `[tools]` `postinstall` hook.
  Write the literal value there.

  ```toml
  [tools.go]
  version = "1.26.2"
  postinstall = "mise install --force gopls goimports gofumpt"
  ```

### Where there is none

A container image tag, and anything else a manager records in one place only.

- The declared version is the whole pin, so it has to name the patch itself.
  There is no second file to fall back on and nothing to reconcile against:
  what is written is what resolves, or nothing is pinned at all.
- A tag that names a line rather than a release is a range wearing a pin's clothes.
  `alpine:3.20` resolves to whatever `3.20.x` the registry holds at pull time,
  so two hosts pulling a week apart run different code
  and nothing in the repo records that they differ.
  `docker:28-cli` is the same failure a level up, and `stable` is the same failure entirely.
  Write `alpine:3.20.7`.
- This is the rule the lockfile enforces automatically elsewhere.
  Nothing enforces it here, which is the reason to state it:
  a compose file is the one place a floating version looks deliberate.
- **Renovate will not add the precision for you.**
  It mirrors whatever precision the pin already has,
  so `alpine:3.20` yields a proposal of `3.24` — another line tag, and still not a pin.
  Making a pin patch-precise is a one-time manual edit;
  Renovate maintains it from then on.
  A repo that adopts this rule has to go through its existing tags once.

A note rather than a rule:
an exact tag is still a mutable reference.
The publisher can move `alpine:3.20.7`, and nothing in the repo would show that it had moved.
The digest is the only form that cannot be moved —
`alpine:3.20.7@sha256:...` — and Renovate maintains it under `pinDigests`.
Worth considering wherever an image reaches production
and the tag belongs to someone else,
weighed against a digest-only pull request per image every time one is rebuilt.

### The one exception

A personal global mise config — `~/.config/mise/config.toml` — is a developer's own toolchain,
not an input to anyone's build,
and its declared versions stay at the minor line on purpose.
Nothing is reproduced from it and no second machine has to agree with it.

Every other pin is in scope, including a repo's own `mise.toml`,
whose lockfile is what makes it exact.

Task conventions are in [tasks.md](tasks.md);
what keeps tool versions moving is in [dependencies.md](dependencies.md).
