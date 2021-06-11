#!/bin/bash

set -e -x -u

LATEST_GIT_TAG=$(git describe --tags | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
VERSION="${1:-$LATEST_GIT_TAG}"

go fmt ./cmd/... ./pkg/... ./test/...
go mod vendor
go mod tidy

# makes builds reproducible
export CGO_ENABLED=0
LDFLAGS="-X github.com/k14s/kbld/pkg/kbld/version.Version=$VERSION -buildid="

GOOS=darwin GOARCH=amd64 go build -ldflags="$LDFLAGS" -trimpath -o kbld-darwin-amd64 ./cmd/kbld/...
GOOS=linux GOARCH=amd64 go build -ldflags="$LDFLAGS" -trimpath -o kbld-linux-amd64 ./cmd/kbld/...
GOOS=windows GOARCH=amd64 go build -ldflags="$LDFLAGS" -trimpath -o kbld-windows-amd64.exe ./cmd/kbld/...

shasum -a 256 ./kbld-darwin-amd64 ./kbld-linux-amd64 ./kbld-windows-amd64.exe
