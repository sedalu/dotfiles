---
name: reference-repos
description: Read upstream source, docs, and implementation details from local git checkouts under $REF_REPOS_DIR instead of fetching over the network. Use whenever a question is best answered by a project's own source — how a tool or library actually behaves, what a CLI's flags really are, what a config schema accepts, whether an API exists in the installed version — or when an answer should cite upstream code by file and line. Also use before answering from memory about any third-party tool, and when a needed repo is not checked out yet.
---

## Why

Answering from memory about a third-party tool is how stale flags, invented options, and behavior that was true two releases ago get presented as fact.
Upstream source is the authority.
These checkouts make consulting it cheap enough that there is no excuse not to.

## Layout

Checkouts live under `$REF_REPOS_DIR` (`~/.cache/ref`), keyed by remote:

```text
$REF_REPOS_DIR/<host>/<owner>/<repo>
```

For example `~/.cache/ref/github.com/jdx/mise`, `~/.cache/ref/codeberg.org/forgejo/forgejo`.
The path is derived from the clone URL, never chosen —
so two projects sharing a name never collide,
and the path always says who publishes the code.

## Using them

**Find what is already checked out** — `mise run ref:list`.
The output is `<host>/<owner>/<repo>`, one per line.

**Get a repo, whether or not it exists yet** — `mise run ref:get <repo>`.
Name it by its checkout path — `github.com/jdx/mise`, `codeberg.org/forgejo/forgejo` — or pass a full clone URL.
It clones if absent, fast-forwards if present, and prints the checkout path either way.
Run it before reading a repo you did not just clone:
a checkout that has sat for a month answers questions about a month-old release.

**Clone freely.**
If a question would be better answered by source that is not here yet,
fetch it.
There is no inventory to update and nothing to ask permission for.

## Rules

- **Read-only.**
  These are upstream repos.
  Never commit, never edit, never leave scratch files in one.
  If you need to try a change,
  copy the file elsewhere.
- **Disposable.**
  The tree is a cache.
  It can be wiped at any time and rebuilt from the clone URLs,
  so nothing that matters may live only here.
- **Cite precisely.**
  Once source is local,
  an answer can name `path/to/file.go:120` instead of gesturing at a project.
  Prefer that.

## Searching large checkouts

Some of these repos are hundreds of megabytes,
and a few hold generated artifacts (`forge.taildfeaeb.ts.net/seth/iso20022` is a six-figure-line XMI dump).
Search before reading:
`rg` for the symbol, flag, or error string,
then open only the file and range that matched.
Reading a whole file to find one function wastes the context the checkout was supposed to save.
