# Logging

Diagnostics are structured records, never formatted strings.
A log line is queried, not read,
so every varying part of it is a named field rather than text spliced into a message.
The message itself is a constant.

## The logger

One logger is constructed at the entry point and passed down explicitly.
Never a package-level global, never the library's default instance,
and never a package that reaches for the logger itself instead of being handed one.

Injection is not a style preference.
It is what makes log output assertable:
a test constructs a logger over a buffer it owns
and inspects what the code under test actually emitted.
A global cannot be substituted per test, so behaviour that only shows up in logs goes untested.

## Levels

Levels carry defined meanings, so a filter means the same thing in every service:

| Level | Means                                                          |
| ----- | -------------------------------------------------------------- |
| ERROR | The operation failed and someone has to look at it              |
| WARN  | Degraded but handled — the operation continued                  |
| INFO  | A state change worth reconstructing later                       |
| DEBUG | Detail for a developer, off outside development                 |

An error that a caller handles is not logged at ERROR by the callee.
Wrapping carries the context upward;
logging at every layer turns one failure into a page of unrelated-looking records.
Log an error once, at the boundary that decides what to do about it.

## What never appears

Secrets, credentials, tokens, and personal data never reach a log line —
including inside a wrapped error message, which is where they arrive by accident.
A value that cannot be logged is redacted at the type that holds it,
so no call site has to remember.
