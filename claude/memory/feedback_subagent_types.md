---
name: feedback_subagent_types
description: "Use the correct subagent type — Explore for local search, general-purpose for web/external requests"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 04f31059-d1a4-405b-a8ad-20eb3eb69d91
---

Match the subagent type to the task:
- **Explore** — local file search only: find files by pattern, grep for symbols, locate definitions. No web access.
- **general-purpose** — use for web fetches, GitHub URLs, external documentation, API calls, or any task requiring internet access.
- **Plan** — architecture and implementation design.
- **claude-code-guide** — Claude Code / API / SDK questions.

**Why:** Repeated failures across Sonnet sessions where Explore agents were dispatched for GitHub URL lookups. Explore can't fulfill web requests, so the research came back flawed and the main agent had to be corrected multiple times.

**How to apply:** Before spawning any subagent, check whether the task touches local files (→ Explore) or external resources (→ general-purpose). When in doubt, use general-purpose.
