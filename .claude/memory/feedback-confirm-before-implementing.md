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

**Why:** This has happened twice in the Helix keybindings work.
First: "nice getting my opinion before going for it" after I implemented the C-c/C-x/C-v clipboard mapping
without pausing. Later (and worse): the user asked an *informational* question
("are there bindings for file-start/end, competing bindings, complications?")
and in the follow-up affirmed a *principle* ("control substitution for command is acceptable in the terminal").
I treated the affirmed principle as authorization and edited config.toml — the user erupted ("WTF! I didn't ok any change").

**How to apply:** After laying out a recommendation with a real fork, stop and let the user choose.
Only an explicit, action-directed "do it / yes / implement / use X" is the go-ahead.
A clear directive ("consistency", "use A-w") IS the go-ahead — implement then.
But an informational question, a discussion of tradeoffs, or the user agreeing with a *principle*
is NOT permission to edit — answer or discuss, then ask "want me to implement this?" and wait.
When in doubt, end the turn with the question, not the edit.
Validation steps and obvious low-risk additive changes don't need a gate.
Relates to [[feedback-verify-tool-source-before-config]].
