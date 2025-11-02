#!/bin/bash
# Calculate SHA256 hash for release tarball

VERSION="${1:-v5.1}"
REPO="${2:-mwangiiharun/hermes}"

echo "Calculating SHA256 for version: $VERSION"
echo "Repository: $REPO"
echo ""

URL="https://github.com/$REPO/archive/refs/tags/$VERSION.tar.gz"

echo "Fetching release tarball..."
SHA256=$(curl -sL "$URL" | shasum -a 256 | cut -d' ' -f1)

if [ -z "$SHA256" ]; then
    echo "❌ Error: Could not calculate SHA256. Make sure the release exists."
    exit 1
fi

echo "✅ SHA256: $SHA256"
echo ""
echo "Update Formula/hermes.rb with this value:"
echo "  sha256 \"$SHA256\""
echo ""
echo "Quick update command:"
echo "  sed -i '' 's/sha256 \".*\"/sha256 \"$SHA256\"/' Formula/hermes.rb"

