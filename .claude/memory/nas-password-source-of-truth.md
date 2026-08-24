---
name: nas-password-source-of-truth
description: macOS Passwords.app is the authoritative store for homelab passwords; fnox and the Samba passdb are downstream caches
metadata: 
  node_type: memory
  type: project
  originSessionId: 36186a78-3fba-4f60-b8a6-9882a81ddb8e
  modified: 2026-08-17T02:37:29.070Z
---

Every homelab password is stored in macOS' Passwords.app, which is the source of truth.
fnox (macOS Keychain) is populated from it, and derived state like Samba's
`/var/lib/samba/private/passdb.tdb` is rebuilt from fnox by `mise run credentials`.

**Why:** it changes what counts as a backup gap. The passdb is captured by no snapshot —
it sits outside `/etc` and both ZFS pools — but that is a rebuild step, not data loss,
because the passwords survive independently.

**How to apply:** don't propose backing up the passdb or other derived credential stores;
propose verifying the Passwords.app entries and the path that repopulates fnox.
See [[feedback-store-all-passwords-in-fnox]].
