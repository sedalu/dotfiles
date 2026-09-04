# Local services

Applies when the repo runs containers or long-lived daemons on a developer machine.

## Container runtime

There is no Docker Desktop.
On macOS the daemon comes from colima, declared in two places:

- **The tool chain**, in the mise config: `lima <- colima <- docker-cli`, wired with `depends`.
- **The daemon**, in `.config/pitchfork.toml`, with `ready_cmd = "docker info"`.

`os`-gate the VM chain (`os = ["macos"]`) in any config that also loads on Linux —
a server host or a CI job container, where the daemon is native and colima is wrong.
mise skips a tool whose `os` does not match, resolving `docker-cli` with no VM under it.

Set `DOCKER_HOST` only where something needs it.
Docker SDK consumers such as testcontainers require it, because they ignore docker CLI contexts.
It is wrong in a repo that only shells out to the `docker` CLI:
a hardcoded macOS socket path in `[env]` follows the config onto Linux
and points a native daemon at a socket that does not exist.

## Daemons

pitchfork manages local daemons, with health checks and dependency ordering.
Infrastructure runs as containers; application services run as native binaries.
Runtime lifecycle dependencies between them are pitchfork `depends` entries.

Docker Compose is not used in local development.
