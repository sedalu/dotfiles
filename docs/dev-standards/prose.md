# Prose and comments

## Semantic line breaks

Prose and comments use [semantic line breaks](https://sembr.org):
one clause or sentence per line, never greedy wrapping to a column.
This applies to Markdown *and* to comments in every file type — shell, TOML, YAML, pkl, Go.

Break after sentences and at major clause boundaries:
before coordinating and subordinating conjunctions, and after colons and semicolons.
Break before a list.
Let a line run as long as its one semantic unit requires.
There are no line-length limits; `MD013` is disabled for this reason.

Never break inside a hyphenated word,
and never break where the newline is syntactically significant —
a table row, a code fence, YAML frontmatter.
A break changes neither what renders nor what parses:
in Markdown it must not become a hard break,
and in a comment the next line carries its own `#` or `//`.

The rule holds for short comments too.
A two-line comment breaks at its clause boundary like any other.

Before finishing any prose or comment,
re-read it and confirm each line ends at a clause boundary rather than a wrap point.

## What a comment is for

A comment states a constraint the code cannot show —
why a value is what it is, which invariant a line protects,
that something is a security control rather than a tuning knob.

A comment never narrates what the next line does.
A comment never records history:
what moved, what it used to be, what changed in this edit.
Git holds that, and a comment repeating it goes stale the moment the next edit lands.

Rationale and architecture belong in the repo's `CLAUDE.md` and its design docs under `docs/`,
not in task or config files.

## Documents

A standards or design document states rules in the imperative.
It does not narrate incidents, tell the story of how a rule was discovered,
or mark its own claims as verified.
Keep only the mechanism a reader needs to apply the rule.

A rule that binds only in some situations names the situation, never a repository.
