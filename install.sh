#!/bin/bash
# mac-finder-webp-convert installer
# Usage (one-liner):
#   curl -fsSL https://raw.githubusercontent.com/RafieRosliputra/mac-finder-webp-convert/main/install.sh | bash
set -euo pipefail

REPO="RafieRosliputra/mac-finder-webp-convert"
WORKFLOW="Convert to WebP.workflow"
SERVICES="$HOME/Library/Services"

echo "==> mac-finder-webp-convert installer"

# 1. Check cwebp
if ! command -v cwebp >/dev/null 2>&1; then
    echo "==> cwebp not found. Installing webp via Homebrew..."
    if ! command -v brew >/dev/null 2>&1; then
        echo "ERROR: Homebrew is not installed."
        echo "       Install it first: https://brew.sh"
        exit 1
    fi
    brew install webp
else
    echo "    [ok] cwebp $(cwebp -version | head -1)"
fi

# 2. Download the latest workflow bundle
TMPDIR_WORK=$(mktemp -d)
trap 'rm -rf "$TMPDIR_WORK"' EXIT

echo "==> Downloading workflow..."
curl -fsSL "https://codeload.github.com/${REPO}/tar.gz/refs/heads/main" -o "$TMPDIR_WORK/repo.tar.gz"

tar -xzf "$TMPDIR_WORK/repo.tar.gz" -C "$TMPDIR_WORK"
SRC_DIR=$(find "$TMPDIR_WORK" -maxdepth 2 -type d -name "$WORKFLOW" | head -1)

if [ -z "$SRC_DIR" ]; then
    echo "ERROR: Could not find '$WORKFLOW' in the downloaded archive."
    exit 1
fi

# 3. Install into Services folder (overwrite if exists)
echo "==> Installing to $SERVICES"
mkdir -p "$SERVICES"
rm -rf "$SERVICES/$WORKFLOW"
cp -R "$SRC_DIR" "$SERVICES/$WORKFLOW"

# 4. Flush the pasteboard services cache so Finder sees it immediately
/System/Library/CoreServices/pbs -flush 2>/dev/null || true

echo ""
echo "==> Done! ✓"
echo "    Right-click any image → Quick Actions → Convert to WebP"
