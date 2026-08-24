---
name: feedback-defer-live-host-writes
description: Delay writes to a live host as late as possible; verify read-only per phase and batch the apply into the final cutover
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 36186a78-3fba-4f60-b8a6-9882a81ddb8e
  modified: 2026-08-09T15:49:34.556Z
---

When migrating a live machine to a new config system,
build and verify each phase read-only against the host,
and let the intended diffs accumulate until a single cutover at the end.
Do not apply a phase's changes as that phase closes.

A phase is done when its plan output contains only intended entries —
not when the host has been changed to match.

**Why:** Every apply is a mutation of a machine holding real data and running real services.
Batching them into one reviewed cutover keeps the number of change windows to one,
and keeps every intermediate phase trivially abandonable.

**How to apply:** Default to `--dry-run` / `plan` for the whole build-out;
propose the real converge only at the cutover phase.
Do not offer "apply now so the next phase verifies against a converged baseline" —
per-class verification (`--only <class>`) already isolates each phase without it.

Also a wording note: a handful of small, deliberate diffs is not the host being "unconverged."
That word oversells a machine that is fine and a config that intentionally differs in two known places.
Describe the actual diffs instead.

Related: [[feedback-confirm-before-implementing]]
