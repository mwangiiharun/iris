#!/bin/bash
# Master script to rename Iris to Iris and prepare a complete release
# Combines: rename, prepare-release, setup-tap, and calculate-sha256

set -e

# Project directories
PROJECTS_DIR="$HOME/projects"
HERMES_DIR="$PROJECTS_DIR/iris"
TAP_DIR="$PROJECTS_DIR/homebrew-tap"
TAP_NAME="${TAP_NAME:-homebrew-tap}"
GITHUB_USER="${GITHUB_USER:-mwangiiharun}"
FORMULA_NAME="iris"

# Default version
VERSION="${1:-v5.2}"
REPO="mwangiiharun/iris"  # Keep repo name as iris

# Change to iris directory
cd "$HERMES_DIR" || {
    echo "❌ Error: Could not find $HERMES_DIR"
    exit 1
}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  🚀 Iris Release Automation Script${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo ""
echo "Version: $VERSION"
echo "Working directory: $HERMES_DIR"
echo "Tap directory: $TAP_DIR"
echo ""

# Confirmation
echo -e "${YELLOW}This script will:${NC}"
echo "  1. Rename Iris to Iris in all files"
echo "  2. Prepare release with version $VERSION"
echo "  3. Set up/update Homebrew tap"
echo "  4. Calculate SHA256 and update formulas"
echo "  5. Commit and push changes to git"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

# ============================================================
# STEP 1: Rename Iris to Iris
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Step 1: Renaming Iris to Iris${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

# Step 1.1: Rename binary
if [ -f "bin/iris" ]; then
    mv bin/iris bin/iris
    echo -e "${GREEN}✓${NC} Renamed bin/iris -> bin/iris"
elif [ -f "bin/iris" ]; then
    echo -e "${YELLOW}⚠${NC}  bin/iris already exists, skipping rename"
else
    echo -e "${RED}❌${NC} Neither bin/iris nor bin/iris found!"
    exit 1
fi

# Step 1.2: Update binary content
if [ -f "bin/iris" ]; then
    # Update script references (but keep repo URLs as iris)
    sed -i '' 's/Iris/Iris/g' bin/iris
    sed -i '' 's/HERMES/IRIS/g' bin/iris
    sed -i '' 's/iris_history/iris_history/g' bin/iris
    sed -i '' 's/iris_realtime/iris_realtime/g' bin/iris
    sed -i '' 's/# ⚡ Iris/# ⚡ Iris/g' bin/iris
    sed -i '' 's/⚡ Iris/⚡ Iris/g' bin/iris
    sed -i '' 's/log_file="\$HOME\/.iris_history"/log_file="$HOME\/.iris_history"/' bin/iris
    sed -i '' 's/tmp_file="\/tmp\/iris_realtime.json"/tmp_file="\/tmp\/iris_realtime.json"/' bin/iris
    echo -e "${GREEN}✓${NC} Updated script content"
fi

# Step 1.3: Update Formula
if [ -f "Formula/iris.rb" ]; then
    # Create iris.rb from iris.rb
    sed -e 's/class Iris/class Iris/g' \
        -e 's/desc "⚡ Iris/desc "⚡ Iris/g' \
        -e 's/"iris"/"iris"/g' \
        -e 's/#{bin}\/iris/#{bin}\/iris/g' \
        -e 's/bin\/iris/bin\/iris/g' \
        Formula/iris.rb > Formula/iris.rb
    echo -e "${GREEN}✓${NC} Created Formula/iris.rb"
fi

# Step 1.4: Update other files
echo "   Updating documentation and scripts..."
for file in README.md INSTALL.md HOMEBREW_SETUP.md RELEASE_CHECKLIST.md RELEASE_NOTES*.md Makefile .gitignore; do
    if [ -f "$file" ]; then
        sed -i '' 's/Iris/Iris/g' "$file" 2>/dev/null || true
        sed -i '' 's/iris/iris/g' "$file" 2>/dev/null || true
        # Fix repo URLs back to iris
        sed -i '' 's|github.com/mwangiiharun/hermes|github.com/mwangiiharun/hermes|g' "$file" 2>/dev/null || true
    fi
done

# Update scripts
for file in scripts/*.sh; do
    if [ -f "$file" ]; then
        sed -i '' 's/iris/iris/g' "$file" 2>/dev/null || true
        sed -i '' 's/Iris/Iris/g' "$file" 2>/dev/null || true
        sed -i '' 's|github.com/mwangiiharun/hermes|github.com/mwangiiharun/hermes|g' "$file" 2>/dev/null || true
    fi
done

echo -e "${GREEN}✓${NC} Step 1 complete"

# ============================================================
# STEP 2: Prepare Release
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Step 2: Preparing Release $VERSION${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

# Step 2.1: Update version in binary
if [ -f "bin/iris" ]; then
    CURRENT_VERSION=$(grep -E '^VERSION=' bin/iris | head -1 | cut -d'"' -f2)
    sed -i '' "s/VERSION=\"$CURRENT_VERSION\"/VERSION=\"$VERSION\"/" bin/iris
    sed -i '' "s/# ⚡ Iris.*(v.*)/# ⚡ Iris — The Messenger of Speed ($VERSION)/" bin/iris
    echo -e "${GREEN}✓${NC} Updated version in binary"
fi

# Step 2.2: Update version file
VERSION_NUM=$(echo $VERSION | sed 's/v//')
echo "$VERSION_NUM" > version
echo -e "${GREEN}✓${NC} Updated version file"

# Step 2.3: Update Formula
if [ -f "Formula/iris.rb" ]; then
    sed -i '' "s/version \"[^\"]*\"/version \"$VERSION_NUM\"/" Formula/iris.rb
    sed -i '' "s|url \"https://github.com/$REPO/archive/refs/tags/[^\"]*\"|url \"https://github.com/$REPO/archive/refs/tags/$VERSION.tar.gz\"|" Formula/iris.rb
    echo -e "${GREEN}✓${NC} Updated Formula/iris.rb"
fi

echo -e "${GREEN}✓${NC} Step 2 complete"

# ============================================================
# STEP 3: Calculate SHA256 and Update Formulas
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Step 3: Calculating SHA256${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

URL="https://github.com/$REPO/archive/refs/tags/$VERSION.tar.gz"

echo "   Fetching release tarball..."
SHA256=$(curl -sL "$URL" | shasum -a 256 | cut -d' ' -f1)

if [ -z "$SHA256" ]; then
    echo -e "${YELLOW}⚠${NC}  Could not calculate SHA256. Tag might not exist yet."
    echo "   You'll need to:"
    echo "   1. Create and push the tag first"
    echo "   2. Then run this script again or update manually"
    SHA256="REPLACE_WITH_REAL_SHA256"
else
    echo -e "${GREEN}✓${NC} SHA256: $SHA256"
    
    # Update iris repo formula
    if [ -f "Formula/iris.rb" ]; then
        sed -i '' "s/sha256 \".*\"/sha256 \"$SHA256\"/" Formula/iris.rb
        echo -e "${GREEN}✓${NC} Updated Formula/iris.rb with SHA256"
    fi
    
    # Update tap repo formula if it exists
    TAP_FORMULA="$TAP_DIR/Formula/${FORMULA_NAME}.rb"
    if [ -f "$TAP_FORMULA" ]; then
        sed -i '' "s/sha256 \".*\"/sha256 \"$SHA256\"/" "$TAP_FORMULA"
        echo -e "${GREEN}✓${NC} Updated tap formula with SHA256"
    fi
fi

echo -e "${GREEN}✓${NC} Step 3 complete"

# ============================================================
# STEP 4: Set Up Homebrew Tap
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Step 4: Setting Up Homebrew Tap${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

# Create tap directory if needed
mkdir -p "$TAP_DIR/Formula"
cd "$TAP_DIR" || exit 1

# Initialize git if needed
if [ ! -d ".git" ]; then
    git init
    echo -e "${GREEN}✓${NC} Initialized git repository"
fi

# Copy formula
if [ -f "$HERMES_DIR/Formula/${FORMULA_NAME}.rb" ]; then
    cp "$HERMES_DIR/Formula/${FORMULA_NAME}.rb" "Formula/${FORMULA_NAME}.rb"
    echo -e "${GREEN}✓${NC} Copied Formula/${FORMULA_NAME}.rb"
else
    echo -e "${RED}❌${NC} Formula not found in iris repo!"
    exit 1
fi

# Create README if it doesn't exist
if [ ! -f "README.md" ]; then
    cat > README.md << EOF
# $TAP_NAME

Homebrew tap for Iris - The Messenger of Speed (formerly Iris)

## Installation

\`\`\`bash
brew tap $GITHUB_USER/$TAP_NAME
brew install $FORMULA_NAME
\`\`\`

## Updating

\`\`\`bash
brew upgrade $FORMULA_NAME
\`\`\`

For more information, visit: https://github.com/$GITHUB_USER/iris
EOF
    echo -e "${GREEN}✓${NC} Created README.md"
fi

# Configure git remote
REMOTE_URL="git@github.com:$GITHUB_USER/$TAP_NAME.git"
if git remote get-url origin >/dev/null 2>&1; then
    CURRENT_REMOTE=$(git remote get-url origin)
    if [[ "$CURRENT_REMOTE" != "$REMOTE_URL" ]]; then
        git remote set-url origin "$REMOTE_URL"
        echo -e "${GREEN}✓${NC} Updated git remote"
    else
        echo -e "${GREEN}✓${NC} Git remote already configured"
    fi
else
    git remote add origin "$REMOTE_URL" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Added git remote"
fi

echo -e "${GREEN}✓${NC} Step 4 complete"

# ============================================================
# STEP 5: Git Operations
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Step 5: Git Operations${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

read -p "Commit and push all changes? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Commit and push iris repo
    echo ""
    echo "📤 Iris repository:"
    cd "$HERMES_DIR"
    
    if [[ -n $(git status --porcelain) ]]; then
        git add .
        git commit -m "Rename Iris to Iris and prepare $VERSION release" || echo "   ⚠️  Commit failed or nothing to commit"
        
        BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
        echo "   Pushing to origin $BRANCH..."
        git push origin "$BRANCH" || echo "   ⚠️  Push failed"
        echo -e "${GREEN}✓${NC} Iris repo pushed"
    else
        echo "   No changes to commit"
    fi
    
    # Create and push tag
    if git rev-parse "$VERSION" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠${NC}  Tag $VERSION already exists"
        read -p "   Delete and recreate? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git tag -d "$VERSION"
            git push origin ":refs/tags/$VERSION" 2>/dev/null || true
        fi
    fi
    
    if ! git rev-parse "$VERSION" >/dev/null 2>&1; then
        git tag "$VERSION"
        echo "   Pushing tag $VERSION..."
        git push origin "$VERSION" || echo "   ⚠️  Tag push failed"
        echo -e "${GREEN}✓${NC} Tag pushed"
    fi
    
    # Commit and push tap repo
    echo ""
    echo "📤 Tap repository:"
    cd "$TAP_DIR"
    
    git add .
    if [[ -n $(git status --porcelain) ]]; then
        git commit -m "Update ${FORMULA_NAME} to $VERSION" || echo "   ⚠️  Commit failed"
    fi
    
    BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    echo "   Pushing to origin $BRANCH..."
    git push -u origin "$BRANCH" 2>/dev/null || {
        echo -e "${YELLOW}⚠${NC}  Push failed. Make sure:"
        echo "      - GitHub repository '$TAP_NAME' exists"
        echo "      - You have push access"
        echo "      - SSH keys are configured"
    }
    echo -e "${GREEN}✓${NC} Tap repo pushed"
    
    echo ""
    echo -e "${GREEN}✅ All git operations complete!${NC}"
else
    echo ""
    echo "Skipping git operations. You can commit and push manually later."
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  ✅ Release Preparation Complete!${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo ""
echo "📋 Summary:"
echo "   Version: $VERSION"
echo "   Binary: bin/iris"
echo "   Formula: Formula/iris.rb"
echo "   SHA256: ${SHA256:0:20}..."
echo "   Tap: $TAP_DIR"
echo ""
echo "📝 Next steps:"
echo "   1. Test: ./bin/iris --version"
echo "   2. Create GitHub release (if not already done)"
echo "   3. Install from tap:"
echo "      brew tap $GITHUB_USER/$TAP_NAME"
echo "      brew install $FORMULA_NAME"
echo ""
if [ "$SHA256" = "REPLACE_WITH_REAL_SHA256" ]; then
    echo -e "${YELLOW}⚠${NC}  Remember to:"
    echo "   1. Create git tag: git tag $VERSION && git push origin $VERSION"
    echo "   2. Run: curl -sL $URL | shasum -a 256"
    echo "   3. Update Formula/iris.rb with the SHA256"
    echo ""
fi

