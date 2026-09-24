# Go

| File                         | Covers                                                         |
| ---------------------------- | -------------------------------------------------------------- |
| [layout.md](layout.md)       | Package layout, `internal/`, and naming                        |
| [api.md](api.md)             | What may appear in an exported signature                       |
| [style.md](style.md)         | Formatting and construct-level rules                           |
| [errors.md](errors.md)       | Wrapping, sentinels, typed errors, panics                      |
| [logging.md](logging.md)     | `log/slog` — the Go realization of [logging.md](../logging.md) |
| [testing.md](testing.md)     | Test names, fixtures, and the test runner                      |
| [toolchain.md](toolchain.md) | Pinning Go, and the tools that move with it                    |

Test structure and tiers are language-independent:
[testing.md](../testing.md) in the practices set holds them,
and the Go file above carries only what Go adds.
