# Documentation

Every repo carries three documents at its root, and they do not overlap:

| Document    | Answers                                                        |
| ----------- | -------------------------------------------------------------- |
| `README.md` | What this is, and how to get it running                        |
| `CLAUDE.md` | How to work in this repo — layout, conventions, the tasks to use |
| `docs/`     | Why it is built this way                                        |

`README.md` is for someone deciding whether they care.
It stays short, and it never becomes the place design decisions accumulate.

`CLAUDE.md` is operational: where things live, which task to run, what a contributor must not do.
It states conventions, not their justification.
A rule in it that needs a paragraph of reasoning has its reasoning in `docs/`.

## Where design docs live

`docs/` holds design and requirements, in subdirectories once there is more than a file of each —
`docs/design/`, `docs/requirements/`.

`.github/` and `.forgejo/` are reserved for files the forge itself consumes:
workflows, issue and pull-request templates, `CODEOWNERS`, `renovate.json5`.
A document no tool reads does not belong there.
It is a discovery path, not a documentation directory,
and a design doc placed in it is found by nobody browsing the repo.

## Generated documents

A generated document is produced by a task and never edited by hand.
It carries no warning comment asking the reader not to edit it —
the task name is the fact worth recording, so state that instead.

Every generated document is excluded from formatters and linters,
or the pipeline and the generator rewrite each other's output indefinitely.
That exclusion belongs in the hk config's shared exclude list — see [linting.md](linting.md).

## Style

How to write any of these is in [prose.md](prose.md).
