---
name: feedback-store-all-passwords-in-fnox
description: "Seth wants every password stored in fnox, including ones no script reads; scope them with profiles rather than leaving them out"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 36186a78-3fba-4f60-b8a6-9882a81ddb8e
  modified: 2026-08-10T00:53:01.627Z
---

When a project uses fnox, Seth wants **all** related passwords recorded there —
not just the ones automation consumes.
Asked about the NAS root and admin account passwords, which no task reads,
his answer was "regardless of script usage, i'd like to store all passwords together."

**Why:** fnox is his single place to look for a credential.
Arguing that a human-typed password "belongs in a password manager, not fnox" is a distinction he doesn't want.

**How to apply:** store them, but don't widen the blast radius to do it.
Put values no task reads in a non-default fnox profile
(`[profiles.vault.secrets.NAME]`, written with `fnox set … --write-profile vault`).
`fnox exec` resolves only the default profile,
so they stay in the same file and keychain namespace without ever entering a task's environment —
which matters when one of them, like a sudo password, is the last thing requiring a human to be present.

Related: [[feedback-confirm-before-implementing]].
