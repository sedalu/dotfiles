---
name: forgejo-actions-logs-via-ssh
description: How to read Forgejo Actions job logs for the homelab forge — ssh to the host, read them out of the forgejo container
metadata:
  type: reference
---

Forgejo Actions job logs are not reachable through `fj` (it only lists tasks)
and not readable anonymously over HTTP, even for a public repo.
Read them over SSH instead:

```sh
ssh heighligner@heighligner \
  'docker exec forgejo sh -c "find /data/gitea/actions_log/<owner>/<repo> -type f | sort | tail -2"'
ssh heighligner@heighligner \
  'docker exec forgejo cat /data/gitea/actions_log/<owner>/<repo>/<shard>/<task>.log.zst | zstdcat'
```

The forge is `forge.taildfeaeb.ts.net`, hosted on `heighligner` over Tailscale SSH.
`docker` works without sudo there; `sudo` does not, since it prompts for a password.
The container has no zstd, so decompress on the host — pipe `cat` into the host's `zstdcat`.

Related: [[nas-password-source-of-truth]].
