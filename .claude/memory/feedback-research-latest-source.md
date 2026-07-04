---
name: feedback-research-latest-source
description: "When researching from source code (incl. ~/Projects/ref checkouts), update to latest first unless told otherwise"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 78c95dda-d1b9-421a-b1c3-e7d13a419d64
---

When researching a question using source code, ensure you're looking at the **latest** version before drawing conclusions, unless the user says otherwise.

**Why:** A stale checkout can produce wrong line numbers, miss a fix, or describe behavior that no longer matches the user's installed version.
In one case I researched a mise bug against a `~/Projects/ref/mise` checkout that was 22 commits behind the user's running build.
That same stale tree led me to assert "no migration command exists" — but `mise bootstrap packages import` had been added in the commits I hadn't pulled.

Never make a definitive **negative** claim (feature/command/option "doesn't exist") from a checkout you haven't refreshed — absence in stale source is not absence in the latest.

**How to apply:**
- For `~/Projects/ref/` checkouts, `git fetch` and fast-forward to the default branch before reading
  (CLAUDE.md already says to pull when a repo looks stale — treat "about to research" as that trigger).
- After updating, re-verify any line numbers / function bodies you cite still match.
- Use system git (`/usr/bin/git`) in ref repos to avoid the mise `mise.toml` trust prompt wrapping `git`.

Related: [[feedback-verify-tool-source-before-config]] (verify from upstream source, not memory).
