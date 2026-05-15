# Course Builder CLI

Public release channel for the Course Builder `cb` CLI and agent skills.

## Install the CLI

Install the latest portable Bun-compiled binary:

```sh
curl -fsSL https://github.com/badass-courses/coursebuilder-cli/releases/latest/download/install.sh | sh
```

Install a specific release:

```sh
curl -fsSL https://github.com/badass-courses/coursebuilder-cli/releases/latest/download/install.sh | sh -s -- --version cb-v0.3.1
```

The installer supports macOS and Linux on arm64/x64, downloads the matching release asset, and verifies `cb-checksums.txt` when `sha256sum` or `shasum` is available.

## Install the Just React creator agent skill

Install the skill globally for your agent:

```sh
npx skills add -y -g badass-courses/coursebuilder-cli --skill just-react-creator
```

The skill teaches an agent how to use `cb` with Just React, create/update sketch posts, add local images through signed S3 URLs, and upload video through multipart upload.

## Release assets

Binaries are attached to `cb-v*` GitHub Releases:

- `cb-darwin-arm64.tar.gz`
- `cb-darwin-x64.tar.gz`
- `cb-linux-arm64.tar.gz`
- `cb-linux-x64.tar.gz`
- `cb-checksums.txt`
