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
The test runner is gotestsum — see [testing.md](testing.md).
Because `go mod tidy` is a gate, `go.sum` has to arrive tidy from whoever wrote it:
[dependencies.md](../dependencies.md) covers what that asks of Renovate.

golangci-lint enables a named set rather than inheriting one:
errcheck, govet, ineffassign, staticcheck, and unused, from `default: "none"`.
errcheck's `check-blank` forbids discarding an error into `_`,
so a function whose write can fail returns the error, and `main` reports it.
[examples/golangci.yaml](../examples/golangci.yaml) is the whole config.

Output of a generator this repo owns is linted — see [linting.md](../linting.md).
golangci-lint sets `exclusions.generated: "disable"`,
gosec runs without `-exclude-generated`,
and goimports and gofumpt exclude nothing.

Every tool that reads Go source is rebuilt when the toolchain moves,
or it parses new source as an older language.
That is the general rule in [tooling.md](../tooling.md);
in Go it reaches gopls, goimports, govulncheck, gofumpt, gosec, and golangci-lint.

A rebuild does not teach a tool a Go release it does not support yet.
golangci-lint vendors its own analysis stack — `x/tools` and staticcheck —
so a release older than the pinned Go cannot parse that release's standard library source:
staticcheck's buildir pass panics,
and every check standing on it goes down with it, govet's nilness included.
Raise the linter to a release whose notes name that Go version;
pinning Go back is not the fix.
Which standard library files a build compiles depends on the platform,
so a clean run on a developer's machine does not prove the runner's — CI settles it.

The vendored staticcheck also decides which struct tags are legal.
golangci-lint 2.12 and earlier report json/v2's `embed` option as SA5008;
2.13 vendors the staticcheck that knows it.
That is a reason to raise the linter, never to suppress the report.
