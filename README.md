# Course Builder CLI

Public release channel for the Course Builder `cb` CLI.

Install the latest portable Bun-compiled binary:

```sh
curl -fsSL https://raw.githubusercontent.com/badass-courses/coursebuilder-cli/main/install.sh | sh
```

Install a specific release:

```sh
curl -fsSL https://raw.githubusercontent.com/badass-courses/coursebuilder-cli/main/install.sh | sh -s -- --version cb-v0.1.0
```

The installer supports macOS and Linux on arm64/x64, downloads the matching release asset, and verifies `cb-checksums.txt` when `sha256sum` or `shasum` is available.

Binaries are attached to `cb-v*` GitHub Releases:

- `cb-darwin-arm64.tar.gz`
- `cb-darwin-x64.tar.gz`
- `cb-linux-arm64.tar.gz`
- `cb-linux-x64.tar.gz`
- `cb-checksums.txt`
