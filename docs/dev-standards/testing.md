# Testing

Tests are written before the implementation, and implementation proceeds until they are green.

## Structure

- Table tests: cases as a named-struct slice, run as subtests.

  ```go
  cases := []struct {
      name     string
      currency string
      wantErr  bool
  }{
      {name: "usd", currency: "USD"},
      {name: "lowercase currency", currency: "usd", wantErr: true},
  }
  ```

- At most one test function per target function or method.
- A test is named after its target, following the language's test-discovery convention.
  A test with no single target — one driving a binary end to end — is named for the behavior it asserts.
- Every test and subtest runs in parallel.
- Unit tests sit in the same package as their target,
  so a test exercises exactly the one thing it names.
  A language whose own convention places them elsewhere overrides this;
  a project's preference does not.

## Dependencies

Scope decides what is real.
Everything inside the test's scope is the real thing;
everything outside it is faked.
The rule is the same at every tier — the tiers differ only in how wide the scope is.

Either way the test owns the state.
Data is reset to a known baseline
and every dependency's lifecycle is driven by the test run,
never shared with another run and never left standing between them.

A unit test's scope is the one target,
so every dependency it has is a test implementation the test drives —
deterministic, and able to be put into any state the target has to handle,
including the failures a real dependency will not produce on command.
That control is what makes the target fully coverable.
Real infrastructure is never inside a unit test's scope.

A feature test's scope is one component together with its own plumbing,
so storage, event buses, caches, and brokers are real instances.
Outside it is the other end of the wire:
another component, the subscriber, the client holding the live connection,
the system a callback is delivered to.
The test stands in that place itself,
which is how it observes what the component actually emitted.

An end-to-end test's scope is every component the scenario touches,
so none of them is doubled.

## Tiers

Separate the tiers by what they boot, and give each its own task:

- **Unit** — white-box, one target, every dependency a test implementation.
- **Feature** — runs the actual binaries of one component.
  It drives the real interface and stands at the far end of the component's channels itself,
  touching storage only to seed and to validate.
  It never imports the component's internal layers.
- **End to end** — boots the real binaries of every component a scenario touches,
  sharing one set of instances among them.
  It reuses the feature tier's scenario corpus parameterized over the real environment,
  rather than a second hand-authored set.
  Negative-path scenarios stay in the feature tier.

A tier a repo has not built yet is absent, not stubbed.
