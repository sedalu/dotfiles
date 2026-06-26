---
name: feedback-yaml-always-quote-strings
description: YAML string values should always be quoted (double quotes); optional quoting is a footgun
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 99620822-010a-45e0-a8a7-22fe5a375a76
---

In YAML, every string value should be explicitly quoted, with double quotes.
The user considers YAML's optional quoting one of the reasons YAML is a bad format,
so quoting is made mandatory rather than left to chance.

**Why:** explicit quotes avoid YAML's type-coercion footguns
(e.g. `no`/`yes`/`on` parsing as booleans, leading-zero numbers as octal).

**How to apply:** in the dotfiles repo this is enforced by `ryl`
(`.config/ryl.toml`: `quoted-strings` `required = true`, `quote-type = "double"`),
with `yamlfmt`'s `force_quote_style: double` as the formatter-side backstop.
ryl is the YAML *linter*; yamlfmt is the *formatter* only (its `-lint` role was replaced by ryl).
When hand-writing or generating YAML anywhere, quote string values by default.
See [[feedback-config-authoring-style]].
