---
name: feedback-migrate-one-app-at-a-time
description: "When migrating multiple similar things (e.g. GUI casks) in one pass, do them one at a time with real verification between each, not batched"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 639918a8-4499-4914-b543-cc92d8d17637
---

For risky/uncertain migrations across several similar targets (e.g. moving several GUI apps
from one install mechanism to another), migrate and verify ONE at a time rather than batching
all of them and verifying at the end.

**Why:** attempted migrating obsidian, steam, and ghostty from the `install-app` hook to mise's
`brew-cask:` backend in one pass ([[project_mise_bootstrap_migration]]), reasoning by analogy
from claude/tailscale-app's earlier successful migration. All three failed identically (Gatekeeper
rejection from corrupted framework bundles) despite the config changes being clean and the
install command reporting success — the failure was only caught by manually running `spctl -a -vv`
after the fact. Batching meant discovering the failure only after all three were already broken,
and required a full multi-file revert. Had ghostty been done alone first, the failure would have
been caught immediately with much less to unwind, and it might have revealed the pattern is
per-cask rather than assuming it'd work for all three.

**How to apply:** when a plan proposes applying the same nontrivial change to N similar targets
(package migrations, config format changes, refactors applied file-by-file), do target #1, run
the real end-to-end verification (not just "the command exited 0" — find the actual authoritative
check, e.g. `spctl -a -vv` for Gatekeeper, not `codesign --verify` which gives false confidence),
and only then proceed to #2..N. This also surfaces early if the change doesn't generalize the way
a single commit-message or prior precedent suggested it would.
