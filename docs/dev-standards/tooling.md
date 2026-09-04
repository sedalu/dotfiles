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

- Declare explicit versions. Never `latest`.
- Change a version with `mise use <tool>@<version>`, or `mise upgrade` to move it forward.
  Both write the config and the lockfile together.
- Set `lockfile = true` so mise creates and maintains `mise.lock`,
  rather than only updating one that already exists.
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
  TOML in general never uses inline tables — write `[table]` and `[parent.child]` sections.
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

Task conventions are in [tasks.md](tasks.md);
what keeps tool versions moving is in [dependencies.md](dependencies.md).
