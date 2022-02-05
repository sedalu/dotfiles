if command -v go >>/dev/null; then
    GOBIN="${$(go env GOBIN):-$(go env GOPATH)/bin}"

    if [[ ! -d "${GOBIN}" ]]; then
        mkdir -p "${GOBIN}"
    fi

    export PATH="${GOBIN}:${PATH}"
fi
