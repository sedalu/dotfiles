---
name: feedback-no-meta-commentary-in-tasks
description: Keep explanatory/architectural commentary out of mise task and config files; it belongs in CLAUDE.md / README / DESIGN.md
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 61fce5c6-9a13-4175-9267-92d446d393f8
  modified: 2026-08-09T22:23:26.009Z
---

Don't put meta commentary — rationale, ordering explanations, "why this works" notes —
in mise task scripts or config files.
Comments there stay at call-site level: what a reader needs right at that line
(e.g. an app's human-readable name next to a numeric ADAM ID).

**Why:** the dotfiles already have documentation homes —
`.claude/CLAUDE.md` for conventions and `docs/DESIGN.md` for architecture.
Explaining the same design twice means two places to drift.

**How to apply:** when a change needs an explanation longer than a line,
write it into `.claude/CLAUDE.md` (conventions, "how to add X")
or `docs/DESIGN.md` (architecture, dependency graphs),
and leave the task/config file clean.

The test for keeping a comment: does it state a fact that changes what an editor would *do*
(a constraint that would otherwise be "simplified" away, a non-obvious upstream behaviour)?
If it only justifies a decision already visible in the code, cut it.
Seth asks for a comment pass explicitly ("check for unnecessary comments") when this slips,
so run that pass before presenting the work, not after.
Related: [[feedback-no-history-comments]], [[feedback-config-authoring-style]].
