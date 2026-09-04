# Shell

Scripts are bash, checked by shellcheck and formatted by shfmt.
zsh is exempt from both — neither tool supports it —
so zsh files carry their conventions by review alone.

## Rules

- A sourced file with no shebang declares `# shellcheck shell=bash` at the top.
- Every `source` is preceded by `# shellcheck source=SCRIPTDIR/…`,
  or `=/dev/null` where the target is genuinely not resolvable.
- Never collect files with `**/*.sh`.
  Task shells do not set `globstar`, so it silently matches one directory level.
  Use `find <dir> -name '*.sh' -exec <tool> {} +`.
- Quote every expansion.
  A `# shellcheck disable=` carries a stated reason, at the narrowest scope that works.
- `shellcheckrc` carries only what is illegal in-file, such as `external-sources`.
  Every other override is a local directive, so the check stays live everywhere else.
- A script that needs a tool fails when the tool is missing, loudly and at the top.
  Degrading to a silent no-op hides a broken run.

## Shell configuration

This section is about rc files that ship to more than one machine.
Scripts are covered above, and take the opposite default.

Configuration must no-op where a tool is absent.
A login shell that errors on a missing tool leaves the machine unusable,
which is a worse outcome than the feature quietly not being there.
Guard on an environment variable the tool sets, not on probing `PATH`.

Split by cost and by shell contract:
environment variables in a file both the login and non-login paths source,
aliases, functions, and interactive setup in a file only interactive shells source.

Cache expensive shell activations rather than running them per shell.
