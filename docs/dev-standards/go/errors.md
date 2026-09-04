# Go errors

## Wrapping

Wrap with `%w` and name the operation that failed, not the error:

```go
return fmt.Errorf("connect nats: %w", err)
```

The message is lowercase and unpunctuated,
so it reads as one clause in the chain a caller finally prints.
It never restates what the wrapped error already says.

Wrap at every boundary the error crosses.
An error returned unwrapped from three layers down names no operation and locates nothing.

## What a package exports

- A condition callers branch on is an exported sentinel:

  ```go
  var ErrCurrencyMismatch = errors.New("currency mismatch")
  ```

- A condition a caller needs *fields* off is an exported struct type.
  `errors.As` asserts to a concrete type, so the caller has to be able to name it —
  an unexported error type is one nothing outside the package can read fields off.
- Everything else stays unexported.
  An error that exists only to be reported to a human needs no identity.

## Comparing

Branch with `errors.Is` and `errors.As`, never on the message text.
String matching breaks the moment a wrap is added, and it breaks silently.

The entry point decides what an expected shutdown means,
which is the one place a sentinel comparison belongs at the top level:

```go
if err := run(log); err != nil && !errors.Is(err, context.Canceled) {
    os.Exit(1)
}
```

## Panics

Panic only for a programmer error the program cannot continue past —
an impossible state, a violated invariant established at construction.
Never for a condition the caller could reasonably encounter, and never across a package boundary.
A library that panics on bad input takes the choice away from its caller.
