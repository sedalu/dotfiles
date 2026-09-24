# Go testing

The Go realization of [testing.md](../testing.md).

- A test is named for its target,
  following the convention the `testing` package documents for `Example` functions:
  `TestF` for a function, `TestT_M` for a method,
  and `Test_f` or `Test_t_M` where the target is unexported —
  `readFile`'s test is `Test_readFile`, never `TestReadFile`.
- Every function and method outside package `main`
  has one test function covering at least one case.
  An `Example` or a `Fuzz` function satisfies that;
  two `Test` functions for one target never do.
- Every test and subtest calls `t.Parallel()`.
- Code that reads files takes an `fs.FS`,
  and its tests pass an `fstest.MapFS`.
  Code that writes takes the write as a function,
  shaped like `os.WriteFile`, which `main` supplies.
- `test:unit` runs `gotestsum --format pkgname -- -race -cover ./...`.
  gotestsum is pinned in mise as `go:gotest.tools/gotestsum`.
  Coverage is reported per package; no profile is written.
- The race detector needs cgo,
  so wherever tests run needs a C compiler and the libc headers —
  `gcc` and `libc6-dev` in a Debian container,
  which is the OS-package exception in [ci.md](../ci.md).
