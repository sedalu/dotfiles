# Go logging

The rules in [logging.md](../logging.md) hold; this is how they are met in Go.

- `log/slog` is the implementation.
  Never `fmt.Print*` or `log.Print*` for diagnostics.
- `main` constructs one `*slog.Logger` and passes it down explicitly.
  Never the package-level `slog` functions, and never `slog.SetDefault` —
  a handler reachable without being passed is the global the injection rule exists to prevent.
- Log through `LogAttrs`, with typed `slog.Attr` values:

  ```go
  log.LogAttrs(ctx, slog.LevelInfo, "order placed",
      slog.String("order_id", id),
      slog.Int64("minor_units", amount.MinorUnits()),
  )
  ```

  Never the variadic key-value convenience methods —
  they take `any`, so a mistyped or odd-length argument list fails at run time rather than compile time.
