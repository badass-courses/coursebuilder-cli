#!/usr/bin/env sh
set -eu

REPO="${CB_RELEASE_REPO:-badass-courses/coursebuilder-cli}"
INSTALL_DIR="${CB_INSTALL_DIR:-${AIHERO_INSTALL_DIR:-$HOME/.local/bin}}"
VERSION="latest"

usage() {
	cat <<'EOF'
Install cb (Course Builder) CLI from public GitHub Releases.

Usage:
  install.sh [--version <tag>] [--install-dir <path>] [--repo <owner/repo>]

Options:
  --version      Release tag (default: latest cb-v* release)
  --install-dir  Install directory (default: ~/.local/bin)
  --repo         GitHub repo (default: badass-courses/coursebuilder-cli)
  -h, --help     Show this help
EOF
}

while [ "$#" -gt 0 ]; do
	case "$1" in
	--version)
		VERSION="$2"
		shift 2
		;;
	--install-dir)
		INSTALL_DIR="$2"
		shift 2
		;;
	--repo)
		REPO="$2"
		shift 2
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "Unknown option: $1" >&2
		usage >&2
		exit 1
		;;
	esac
done

require_command() {
	if ! command -v "$1" >/dev/null 2>&1; then
		echo "Missing required command: $1" >&2
		exit 1
	fi
}

require_command curl
require_command tar

uname_s="$(uname -s)"
uname_m="$(uname -m)"

case "$uname_s" in
Darwin) os="darwin" ;;
Linux) os="linux" ;;
*)
	echo "Unsupported OS: $uname_s" >&2
	exit 1
	;;
esac

case "$uname_m" in
x86_64 | amd64) arch="x64" ;;
arm64 | aarch64) arch="arm64" ;;
*)
	echo "Unsupported architecture: $uname_m" >&2
	exit 1
	;;
esac

if [ "$VERSION" = "latest" ]; then
	releases_json="$(curl -fsSL "https://api.github.com/repos/$REPO/releases?per_page=100")"
	VERSION="$(printf '%s' "$releases_json" |
		tr '\n' ' ' |
		sed 's/},{/}\
{/g' |
		grep -o '"tag_name":"cb-v[^"]*"' |
		head -n 1 |
		cut -d'"' -f4)"

	if [ -z "$VERSION" ]; then
		echo "Could not find any cb-v* release tags in $REPO." >&2
		exit 1
	fi
elif [ "${VERSION#cb-v}" = "$VERSION" ]; then
	VERSION="cb-v$VERSION"
fi

asset="cb-$os-$arch.tar.gz"
base_url="https://github.com/$REPO/releases/download/$VERSION"
download_url="$base_url/$asset"
checksums_url="$base_url/cb-checksums.txt"

tmpdir="$(mktemp -d)"
cleanup() {
	rm -rf "$tmpdir"
}
trap cleanup EXIT INT TERM

echo "Downloading $download_url"
curl -fsSL "$download_url" -o "$tmpdir/$asset"
curl -fsSL "$checksums_url" -o "$tmpdir/cb-checksums.txt"

(
	cd "$tmpdir"
	if command -v sha256sum >/dev/null 2>&1; then
		grep "  $asset$" cb-checksums.txt | sha256sum -c -
	elif command -v shasum >/dev/null 2>&1; then
		grep "  $asset$" cb-checksums.txt | shasum -a 256 -c -
	else
		echo "Warning: sha256sum/shasum not found; skipping checksum verification." >&2
	fi
)

tar -xzf "$tmpdir/$asset" -C "$tmpdir"

mkdir -p "$INSTALL_DIR"
install -m 755 "$tmpdir/cb" "$INSTALL_DIR/cb"

echo "Installed cb $VERSION to: $INSTALL_DIR/cb"

case ":${PATH:-}:" in
*":$INSTALL_DIR:"*) ;;
*)
	echo "Add this to your shell profile:"
	echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
	;;
esac
