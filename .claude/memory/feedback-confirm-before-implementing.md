---
name: feedback-confirm-before-implementing
description: "For non-trivial changes with a real tradeoff, present the recommendation and wait for the user's go-ahead before editing files"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 642c6188-29f6-4619-b2e2-05ef7008e98d
---

When a change involves a genuine decision or tradeoff,
present the recommendation and options, then wait for the user's explicit go-ahead before touching files —
don't slide straight from "here's what I'd do" into editing.

**Why:** During the Helix keybindings work the user said "nice getting my opinion before going for it"
after I implemented the C-c/C-x/C-v clipboard mapping — including the cut-in-insert-vs-completion tradeoff —
without pausing for input, unlike the earlier phases where I confirmed first.

**How to apply:** After laying out a recommendation with a real fork, stop and let the user choose.
A clear directive ("consistency", "use A-w", "do X") IS the go-ahead — implement then.
Validation steps and obvious low-risk additive changes don't need a gate.
Relates to [[feedback-verify-tool-source-before-config]].
