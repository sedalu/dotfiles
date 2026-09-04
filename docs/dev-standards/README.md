# Development standards

Conventions for repositories I own.
A repository owned by someone else keeps its own conventions,
whether it is being consumed or contributed to.

These standards take effect in a repo only when that repo references them explicitly —
in the repo itself, or in its Claude session.

## How to read this

- Every rule is imperative and binding.
  Where a repo differs, the repo is drift to migrate, not a local exception.
- A file that binds only in some situations names that situation in its first line.
  No rule here names a repository.
- Load the file for the topic at hand, not the set.
- An example inside a file is the smallest fragment that makes one rule unambiguous.
  A config whose meaning is in how it composes
  gets a working reference in [examples/](examples/README.md) instead.

## Foundations

Every repo.

| File                               | Covers                                                      |
| ---------------------------------- | ----------------------------------------------------------- |
| [repo-layout.md](repo-layout.md)   | What lives at the root, and how to redirect a tool's config |
| [tooling.md](tooling.md)           | mise, tool selection, and pinning                           |
| [dependencies.md](dependencies.md) | Renovate, grouping, and what may automerge                  |
| [tasks.md](tasks.md)               | The task interface every other topic enters through         |
| [linting.md](linting.md)           | The hk pipeline and which tool owns which concern           |
| [git.md](git.md)                   | Commits, branching, and hooks                               |
| [ci.md](ci.md)                     | Running the same pipeline on a runner                       |

## Practices

| File                                 | Covers                                              |
| ------------------------------------ | --------------------------------------------------- |
| [prose.md](prose.md)                 | Semantic line breaks, comments, and document style  |
| [documentation.md](documentation.md) | Which documents a repo carries, and where they live |
| [testing.md](testing.md)             | Test structure, dependencies, and tiers             |
| [logging.md](logging.md)             | Structured records, logger injection, and levels    |
| [secrets.md](secrets.md)             | fnox, providers, and key handling                   |

## Languages

| File                 | Covers                                                     |
| -------------------- | ---------------------------------------------------------- |
| [go/](go/README.md)  | Layout, API boundaries, style, errors, logging, toolchain  |
| [shell.md](shell.md) | Bash scripts and shell configuration                       |

Add a language file when there is real code to derive it from, not before.

## Situational

Each names its situation in its first line.

| File                                   | Covers                                     |
| -------------------------------------- | ------------------------------------------ |
| [database.md](database.md)             | Query access, schema, migrations           |
| [local-services.md](local-services.md) | Container runtime and local daemons        |
| [deployment.md](deployment.md)         | Deploy workflows and their failure modes   |
| [releases.md](releases.md)             | Tags, changelogs, and published artifacts  |
