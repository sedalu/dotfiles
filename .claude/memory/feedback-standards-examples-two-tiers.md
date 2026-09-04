---
name: feedback-standards-examples-two-tiers
description: "In docs/dev-standards, inline examples stay miniature; whole working configs go in examples/"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: fdddbfa8-b499-4a1e-806d-5979a1bb9d47
  modified: 2026-09-04T18:19:34.068Z
---

Examples in `docs/dev-standards/` come in two tiers, and the split is deliberate.
Inline fences inside a topic file are **miniature** — the smallest fragment that makes one rule
unambiguous, roughly three to eight lines, never a whole file and never a realistic one.
A config whose meaning is in how it *composes* (an hk pipeline, a mise config) gets a full working
file under `docs/dev-standards/examples/`, which the topic file links to.

**Why:** an inline example exists to disambiguate a rule, not to be copied, so a long one buries the
rule it serves. But composition — how hk locals, step mappings, and hooks fit together — is exactly
what a fragment cannot show, so that material needs somewhere else to live rather than being cut.
Files under `examples/` are real, so the hk pipeline lints them and they cannot rot silently.

**How to apply:** when adding an example, ask whether it teaches one rule or a composition. One rule
→ inline, minimal. Composition → `examples/`, with a row in `examples/README.md` giving its real
destination path and the topic file it serves. Check the hk `shellGlob` reaches any extensionless
example. Do not read "keep examples small" as "no examples directory" — I made that mistake once.
See [[feedback-config-authoring-style]] and [[feedback-verify-tool-source-before-config]].
