# Releases

Applies when the repo publishes something a consumer pins —
a library, a module, a distributed binary.
A service that only deploys has no release; see [deployment.md](deployment.md).

The tag is the release. Semantic versioning, and the tag is what CI builds from.

## Deriving the version

The version comes from the conventional commits [git.md](git.md) already requires:

| Commit                        | Bumps |
| ----------------------------- | ----- |
| `fix:`                        | patch |
| `feat:`                       | minor |
| `!` or a `BREAKING CHANGE:` footer | major |

Below `1.0.0` a breaking change bumps the minor,
and consumers are told the API is not yet stable rather than being surprised by it.

The changelog is generated from those commits and never written by hand.
It is a generated document, with everything that implies in [documentation.md](documentation.md).

## Building the artifact

A release artifact is built in CI, from the tag, by the same task a developer runs locally.
Never from a workstation — a local build carries whatever that machine happened to have installed,
which is the state [tooling.md](tooling.md) exists to prevent.

A release is immutable.
A bad release is superseded by the next patch version, never retagged.
