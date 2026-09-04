# Go toolchain

Go is pinned in `[tools]`, never resolved from `go.mod`.
The `go` directive is the module's minimum language version —
a consumer compatibility floor, not the version the project is developed with —
and the `toolchain` directive that would name an exact version
is written conditionally and routinely absent.
`.go-version` is another tool's convention, not Go's, and is not read either.

hk runs goimports and gofumpt as formatters,
golangci-lint and `go mod tidy` on commit,
and govulncheck and gosec on push.

Every tool that reads Go source is rebuilt when the toolchain moves,
or it parses new source as an older language.
That is the general rule in [tooling.md](../tooling.md);
in Go it reaches gopls, goimports, govulncheck, gofumpt, gosec, and golangci-lint.
