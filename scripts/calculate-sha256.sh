#!/bin/bash
# Calculate SHA256 hash for release tarball

VERSION="${1:-v5.2}"
REPO="${2:-mwangiiharun/iris}"
FORMULA_NAME="${3:-iris}"

# Project directories
PROJECTS_DIR="$HOME/projects"
HERMES_DIR="$PROJECTS_DIR/iris"

# Change to iris directory
cd "$HERMES_DIR" 2>/dev/null || {
    echo "⚠️  Warning: Could not find $HERMES_DIR, using current directory"
}

echo "Calculating SHA256 for version: $VERSION"
echo "Repository: $REPO"
echo "Formula: $FORMULA_NAME"
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
echo "Update Formula/${FORMULA_NAME}.rb with this value:"
echo "  sha256 \"$SHA256\""
echo ""
echo "Quick update commands:"
echo "  # In iris repo:"
echo "  sed -i '' 's/sha256 \".*\"/sha256 \"$SHA256\"/' Formula/${FORMULA_NAME}.rb"
echo ""
echo "  # In tap repo ($PROJECTS_DIR/homebrew-tap):"
echo "  sed -i '' 's/sha256 \".*\"/sha256 \"$SHA256\"/' Formula/${FORMULA_NAME}.rb"
echo ""
read -p "Do you want to update the formula files automatically? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Updating formula files..."
    
    # Update iris repo formula
    if [ -f "$HERMES_DIR/Formula/${FORMULA_NAME}.rb" ]; then
        sed -i '' "s/sha256 \".*\"/sha256 \"$SHA256\"/" "$HERMES_DIR/Formula/${FORMULA_NAME}.rb"
        echo "   ✓ Updated $HERMES_DIR/Formula/${FORMULA_NAME}.rb"
    else
        echo "   ⚠️  $HERMES_DIR/Formula/${FORMULA_NAME}.rb not found"
    fi
    
    # Update tap repo formula
    TAP_FORMULA="$PROJECTS_DIR/homebrew-tap/Formula/${FORMULA_NAME}.rb"
    if [ -f "$TAP_FORMULA" ]; then
        sed -i '' "s/sha256 \".*\"/sha256 \"$SHA256\"/" "$TAP_FORMULA"
        echo "   ✓ Updated $TAP_FORMULA"
        
        # Ask if user wants to commit and push tap changes
        read -p "   Commit and push tap changes? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd "$PROJECTS_DIR/homebrew-tap" || exit 1
            git add "Formula/${FORMULA_NAME}.rb"
            git commit -m "Update ${FORMULA_NAME} to $VERSION" || echo "   ⚠️  Commit failed"
            git push origin main 2>/dev/null || {
                BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
                git push origin "$BRANCH" || echo "   ⚠️  Push failed"
            }
            echo "   ✓ Tap updated and pushed"
        fi
    else
        echo "   ⚠️  $TAP_FORMULA not found (tap might not be set up yet)"
    fi
    
    # Ask if user wants to commit iris repo changes
    read -p "Commit SHA256 update in iris repo? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$HERMES_DIR" || exit 1
        git add "Formula/${FORMULA_NAME}.rb"
        git commit -m "Update formula SHA256 for $VERSION" || echo "   ⚠️  Commit failed"
        git push origin main 2>/dev/null || {
            BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
            git push origin "$BRANCH" || echo "   ⚠️  Push failed"
        }
        echo "   ✓ Iris repo updated and pushed"
    fi
fi
echo ""

