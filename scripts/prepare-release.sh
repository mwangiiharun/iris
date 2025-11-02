#!/bin/bash
# Script to prepare a new release after renaming to Iris

set -e

# Project directories
PROJECTS_DIR="$HOME/projects"
HERMES_DIR="$PROJECTS_DIR/iris"
TAP_DIR="$PROJECTS_DIR/homebrew-tap"

# Change to iris directory
cd "$HERMES_DIR" || {
    echo "❌ Error: Could not find $HERMES_DIR"
    exit 1
}

VERSION="${1:-v5.2}"
REPO="mwangiiharun/iris"  # Keep repo name as iris

echo "🚀 Preparing Iris release: $VERSION"
echo "   Working directory: $HERMES_DIR"
echo "   Tap directory: $TAP_DIR"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Step 1: Verify binary exists
echo -e "${GREEN}✓ Step 1: Verifying binary...${NC}"
if [ ! -f "bin/iris" ]; then
    echo -e "${RED}❌ Error: bin/iris not found!${NC}"
    echo "   Run scripts/rename-to-iris.sh first"
    exit 1
fi
echo "   ✓ bin/iris found"

# Step 2: Update version in binary
echo -e "${GREEN}✓ Step 2: Updating version in binary...${NC}"
CURRENT_VERSION=$(grep -E '^VERSION=' bin/iris | head -1 | cut -d'"' -f2)
sed -i '' "s/VERSION=\"$CURRENT_VERSION\"/VERSION=\"$VERSION\"/" bin/iris
sed -i '' "s/# ⚡ Iris.*(v.*)/# ⚡ Iris — The Messenger of Speed ($VERSION)/" bin/iris
echo "   ✓ Updated version to $VERSION"

# Step 3: Update version file
echo -e "${GREEN}✓ Step 3: Updating version file...${NC}"
VERSION_NUM=$(echo $VERSION | sed 's/v//')
echo "$VERSION_NUM" > version
echo "   ✓ Updated version file to $VERSION_NUM"

# Step 4: Update Formula
echo -e "${GREEN}✓ Step 4: Updating Homebrew formula...${NC}"
if [ ! -f "Formula/iris.rb" ]; then
    echo -e "${RED}❌ Error: Formula/iris.rb not found!${NC}"
    exit 1
fi

# Update version in formula
sed -i '' "s/version \"[^\"]*\"/version \"$VERSION_NUM\"/" Formula/iris.rb

# Update URL
sed -i '' "s|url \"https://github.com/$REPO/archive/refs/tags/[^\"]*\"|url \"https://github.com/$REPO/archive/refs/tags/$VERSION.tar.gz\"|" Formula/iris.rb

echo "   ✓ Updated Formula/iris.rb"

# Step 5: Calculate SHA256 (will be placeholder until tag exists)
echo -e "${GREEN}✓ Step 5: Preparing SHA256 calculation...${NC}"
echo "   ⚠️  SHA256 will be calculated after creating git tag"
echo "   URL: https://github.com/$REPO/archive/refs/tags/$VERSION.tar.gz"
echo ""

# Step 6: Update release notes
echo -e "${GREEN}✓ Step 6: Creating release notes...${NC}"
RELEASE_NOTES_FILE="RELEASE_NOTES_${VERSION}.md"
cat > "$RELEASE_NOTES_FILE" << EOF
# 🚀 Iris $VERSION - The Messenger of Speed

## Renamed from Iris to Iris

This release renames the project from Iris to Iris while maintaining all functionality.

### ✨ What Changed

- **Renamed**: Iris → Iris
- All functionality remains the same
- Homebrew formula updated to install as \`iris\`
- Binary name changed from \`iris\` to \`iris\`
- Configuration files now use \`.iris_history\` instead of \`.iris_history\`

### 📦 Installation

**Homebrew:**
\`\`\`bash
brew tap mwangiiharun/homebrew-tap
brew install iris
\`\`\`

**Manual:**
\`\`\`bash
git clone https://github.com/mwangiiharun/hermes.git
cd iris
chmod +x bin/iris
export PATH="\$PATH:\$(pwd)/bin"
\`\`\`

### 🔄 Migration from Iris

If you previously installed Iris:

1. **Uninstall old version:**
   \`\`\`bash
   brew uninstall iris  # if installed via Homebrew
   \`\`\`

2. **Install Iris:**
   \`\`\`bash
   brew install iris
   \`\`\`

3. **Migrate history** (optional):
   \`\`\`bash
   mv ~/.iris_history ~/.iris_history
   \`\`\`

### 📋 Usage

All commands remain the same, just use \`iris\` instead of \`iris\`:

\`\`\`bash
iris              # Run speed test
iris --json       # JSON output
iris --history    # View history
iris --stats      # Statistics
iris --help       # Help
\`\`\`

---

**Repository:** https://github.com/mwangiiharun/hermes (name unchanged)

EOF
echo "   ✓ Created $RELEASE_NOTES_FILE"

# Step 7: Create GitHub release notes
GITHUB_NOTES="RELEASE_NOTES_GITHUB_${VERSION}.md"
cat > "$GITHUB_NOTES" << EOF
# 🚀 Iris $VERSION - The Messenger of Speed

## Renamed from Iris to Iris

This release renames the project from **Iris** to **Iris** while maintaining all functionality.

### What Changed

- ✅ **Renamed**: Iris → Iris
- ✅ All functionality remains the same
- ✅ Homebrew formula updated
- ✅ Configuration uses \`.iris_history\`

### Installation

\`\`\`bash
brew tap mwangiiharun/homebrew-iris
brew install iris
\`\`\`

### Migration

\`\`\`bash
brew uninstall iris  # if previously installed
brew install iris
mv ~/.iris_history ~/.iris_history  # optional
\`\`\`

### Usage

\`\`\`bash
iris              # Run speed test
iris --json       # JSON output
iris --history    # View history
iris --stats      # Statistics
\`\`\`

---

**Repository:** https://github.com/mwangiiharun/hermes

EOF
echo "   ✓ Created $GITHUB_NOTES"

# Step 8: Summary
echo ""
echo -e "${GREEN}✅ Release preparation complete!${NC}"
echo ""
echo "📋 Summary:"
echo "   Version: $VERSION"
echo "   Binary: bin/iris"
echo "   Formula: Formula/iris.rb"
echo "   Release notes: $RELEASE_NOTES_FILE"
echo ""
echo "📝 Next steps:"
echo ""
read -p "Do you want to commit, tag, and push now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${GREEN}📤 Step 9: Committing and pushing to git...${NC}"
    
    # Check if there are changes to commit
    if [[ -n $(git status --porcelain) ]]; then
        echo "   Adding all changes..."
        git add .
        echo "   Committing..."
        git commit -m "Prepare $VERSION release - Rename to Iris"
        echo "   ✓ Committed changes"
        
        # Push to main branch
        echo "   Pushing to origin main..."
        git push origin main || {
            echo -e "${YELLOW}   ⚠️  Push failed or no remote configured${NC}"
        }
    else
        echo "   ✓ No changes to commit"
    fi
    
    # Check if tag exists
    if git rev-parse "$VERSION" >/dev/null 2>&1; then
        echo -e "${YELLOW}   ⚠️  Tag $VERSION already exists${NC}"
        read -p "   Delete and recreate? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git tag -d "$VERSION"
            git push origin ":refs/tags/$VERSION" 2>/dev/null || true
        fi
    fi
    
    # Create and push tag
    echo "   Creating tag $VERSION..."
    git tag "$VERSION"
    echo "   Pushing tag to origin..."
    git push origin "$VERSION" || {
        echo -e "${YELLOW}   ⚠️  Tag push failed${NC}"
    }
    echo "   ✓ Tag pushed"
    
    echo ""
    echo -e "${GREEN}✅ Git operations complete!${NC}"
    echo ""
    echo "Next:"
    echo "   1. Calculate SHA256: ./scripts/calculate-sha256.sh $VERSION iris"
    echo "   2. Update Formula/iris.rb with SHA256"
    echo "   3. Update tap: ./scripts/setup-tap.sh"
    echo "   4. Create GitHub release manually with $GITHUB_NOTES"
else
    echo ""
    echo "Manual steps:"
    echo "   1. Review changes: git diff"
    echo "   2. Test: ./bin/iris --version"
    echo "   3. Commit: git add . && git commit -m \"Prepare $VERSION release\""
    echo "   4. Push: git push origin main"
    echo "   5. Tag: git tag $VERSION && git push origin $VERSION"
    echo "   6. Calculate SHA256: ./scripts/calculate-sha256.sh $VERSION iris"
    echo "   7. Update Formula/iris.rb with SHA256"
    echo "   8. Update tap: ./scripts/setup-tap.sh"
fi
echo ""

