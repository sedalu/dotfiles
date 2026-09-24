# Go layout and naming

- `cmd/` holds one thin main package per binary,
  deployable or not — a repo's own generator lives there too, never under `internal/cmd/`.
  `internal/` holds everything else by default.
- A main package only wires:
  it calls one `Run` in `internal/` with its arguments and dependencies —
  `os.Args`, `os.DirFS`, `os.Stderr`, `os.WriteFile` —
  and exits non-zero on the error it returns.
- A package leaves `internal/` only when another module is meant to import it.
  What that takes is a tree with no `internal/` above it, not a particular depth,
  though the repo root is usually where such a package lands.
- Never use `pkg/`.
- The file holding a package's entry point is named after the package —
  `datatype/datatype.go`, and `cmd/<name>/main.go` for package `main`.
- Avoid stuttering names: `datatype.Money`, never `money.Money`.
- Generated code is marked by a `_gen` file-name suffix, never by a directory name,
  and generated packages live under `internal/` so only their owner can import them.
  `generated` is not an acceptable package name.
