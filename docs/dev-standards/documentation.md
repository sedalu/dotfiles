# Documentation

Every repo carries three documents, and they do not overlap:

| Document    | Lives in   | Answers                                                        |
| ----------- | ---------- | -------------------------------------------------------------- |
| `README.md` | the root   | What this is, and how to get it running                        |
| `CLAUDE.md` | `.claude/` | How to work in this repo — layout, conventions, the tasks to use |
| `docs/`     | `docs/`    | Why it is built this way                                        |

Each sits where its reader looks for it.
`CLAUDE.md` goes in `.claude/`, Claude Code's own discovery path.
`README.md` stays at the root:
GitHub prefers `.github/README.md` over the root,
and Forgejo prefers the root over `docs/`, `.forgejo/`, and `.github/` alike,
so the root is the one placement that renders on both —
which matters the moment a repo is mirrored between forges.

Every other forge-facing file — `CONTRIBUTING.md`, issue and pull-request templates,
`CODEOWNERS`, `renovate.json5`, workflows — lives in the forge directory.

`README.md` is for someone deciding whether they care.
It stays short, and it never becomes the place design decisions accumulate.

`CLAUDE.md` is operational: where things live, which task to run, what a contributor must not do.
It states conventions, not their justification.
A rule in it that needs a paragraph of reasoning has its reasoning in `docs/`.

## Where design docs live

`docs/` holds design and requirements, in subdirectories once there is more than a file of each —
`docs/design/`, `docs/requirements/`.

`.github/` and `.forgejo/` are reserved for files the forge itself consumes:
workflows, issue and pull-request templates, `CONTRIBUTING.md`, `CODEOWNERS`, `renovate.json5`.
A document no tool reads does not belong there.
It is a discovery path, not a documentation directory,
and a design doc placed in it is found by nobody browsing the repo.

## Generated documents

A generated document is produced by a task and never edited by hand.
It carries no warning comment asking the reader not to edit it —
the task name is the fact worth recording, so state that instead.

Whether it is linted turns on who owns the generator, not on its being generated.

A document produced by a generator this repo owns is not excluded.
It is held to the same standard as one written by hand:
if a formatter wants to rewrite it,
the generator is emitting the wrong bytes,
and the generator is what gets fixed.
Excluding it instead hides the defect
and lets the output drift from house style.

A document produced by a vendor's generator is excluded,
like an app-managed file.
Its shape is the vendor's to choose and not ours to correct,
so a formatter pointed at it reformats bytes the vendor re-emits unchanged.
That exclusion belongs in the hk config's shared exclude list — see [linting.md](linting.md).

## Style

How to write any of these is in [prose.md](prose.md).
