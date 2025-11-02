#!/bin/bash
# Script to bump version and deploy Iris

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get current version
CURRENT_VERSION=$(grep -E '^VERSION=' bin/iris | head -1 | cut -d'"' -f2)
CURRENT_VERSION_NUM=$(echo $CURRENT_VERSION | sed 's/v//')

echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  🚀 Iris Version Bump and Deploy${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo ""
echo "Current version: ${CURRENT_VERSION} (${CURRENT_VERSION_NUM})"
echo ""

# Ask for new version
read -p "Enter new version (e.g., v5.3 or just 5.3): " NEW_VERSION_INPUT
if [[ -z "$NEW_VERSION_INPUT" ]]; then
    echo -e "${RED}Error: Version cannot be empty${NC}"
    exit 1
fi

# Normalize version format (ensure it starts with 'v')
if [[ ! "$NEW_VERSION_INPUT" =~ ^v ]]; then
    NEW_VERSION="v${NEW_VERSION_INPUT}"
else
    NEW_VERSION="$NEW_VERSION_INPUT"
fi

NEW_VERSION_NUM=$(echo $NEW_VERSION | sed 's/v//')
PUSHED_TO_GITHUB=false

echo ""
echo -e "${GREEN}New version: ${NEW_VERSION} (${NEW_VERSION_NUM})${NC}"
echo ""

# Confirm
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${CYAN}📝 Step 1: Updating version in files...${NC}"

# Detect OS for sed syntax
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_INPLACE="sed -i ''"
else
    SED_INPLACE="sed -i"
fi

# Update bin/iris
$SED_INPLACE "s/VERSION=\"$CURRENT_VERSION\"/VERSION=\"$NEW_VERSION\"/" bin/iris
$SED_INPLACE "s/# ⚡ Iris.*(v.*)/# ⚡ Iris — The Messenger of Speed ($NEW_VERSION)/" bin/iris
echo -e "  ${GREEN}✓${NC} Updated bin/iris"

# Update version file
echo "$NEW_VERSION_NUM" > version
echo -e "  ${GREEN}✓${NC} Updated version file"

# Update Formula/iris.rb
$SED_INPLACE "s/version \"[^\"]*\"/version \"$NEW_VERSION_NUM\"/" Formula/iris.rb

# Update URL - use a more specific pattern to avoid sed issues
CURRENT_URL=$(grep '^  url "' Formula/iris.rb | head -1)
if [[ -n "$CURRENT_URL" ]]; then
    NEW_URL="  url \"https://github.com/mwangiiharun/iris/archive/refs/tags/$NEW_VERSION.tar.gz\""
    $SED_INPLACE "s|^  url \".*\"|$NEW_URL|" Formula/iris.rb
else
    echo -e "  ${YELLOW}⚠️  Could not find url line in formula${NC}"
fi

# Clear SHA256 (will be calculated after tag)
$SED_INPLACE "s/sha256 \".*\"/sha256 \"PENDING_AFTER_TAG\"/" Formula/iris.rb
echo -e "  ${GREEN}✓${NC} Updated Formula/iris.rb"

echo ""
echo -e "${CYAN}📤 Step 2: Committing changes...${NC}"

# Check if git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "  ${YELLOW}⚠️  Not a git repository, skipping commit${NC}"
else
    git add bin/iris version Formula/iris.rb
    git commit --allow-empty -m "Bump version to $NEW_VERSION" || echo -e "  ${YELLOW}⚠️  Commit failed${NC}"
    echo -e "  ${GREEN}✓${NC} Changes committed"
fi

echo ""
echo -e "${CYAN}🏷️  Step 3: Creating and pushing git tag...${NC}"

if git rev-parse --git-dir > /dev/null 2>&1; then
    # Check if tag already exists
    if git rev-parse "$NEW_VERSION" >/dev/null 2>&1; then
        echo -e "  ${YELLOW}⚠️  Tag $NEW_VERSION already exists${NC}"
        read -p "  Delete and recreate? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git tag -d "$NEW_VERSION" 2>/dev/null || true
            git push origin ":refs/tags/$NEW_VERSION" 2>/dev/null || true
        else
            echo -e "  ${YELLOW}Skipping tag creation${NC}"
            SKIP_TAG=true
        fi
    fi
    
    if [[ "$SKIP_TAG" != "true" ]]; then
        git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION"
        echo -e "  ${GREEN}✓${NC} Tag created: $NEW_VERSION"
        
        read -p "Push to GitHub? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push origin main || echo -e "  ${YELLOW}⚠️  Push to main failed${NC}"
            git push origin "$NEW_VERSION" || echo -e "  ${YELLOW}⚠️  Push tag failed${NC}"
            echo -e "  ${GREEN}✓${NC} Pushed to GitHub"
            PUSHED_TO_GITHUB=true
        else
            echo -e "  ${YELLOW}⚠️  Skipping push - do it manually:${NC}"
            echo "     git push origin main"
            echo "     git push origin $NEW_VERSION"
            PUSHED_TO_GITHUB=false
        fi
    fi
else
    echo -e "  ${YELLOW}⚠️  Not a git repository, skipping tag${NC}"
fi

echo ""
echo -e "${CYAN}📊 Step 4: Calculating SHA256...${NC}"

# Wait a moment for GitHub to process the tag
if git rev-parse --git-dir > /dev/null 2>&1 && [[ "$SKIP_TAG" != "true" ]]; then
    echo "  Waiting 3 seconds for GitHub to process tag..."
    sleep 3
    
    URL="https://github.com/mwangiiharun/iris/archive/refs/tags/$NEW_VERSION.tar.gz"
    echo "  Fetching: $URL"
    
    SHA256=$(curl -sL "$URL" | shasum -a 256 | cut -d' ' -f1)
    
    if [[ -z "$SHA256" ]]; then
        echo -e "  ${RED}❌ Could not calculate SHA256. Tag may not be available yet.${NC}"
        echo -e "  ${YELLOW}Run manually later:${NC}"
        echo "     ./scripts/calculate-sha256.sh $NEW_VERSION"
    else
        echo -e "  ${GREEN}✓${NC} SHA256: $SHA256"
        
        # Update formula with SHA256
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/sha256 \".*\"/sha256 \"$SHA256\"/" Formula/iris.rb
        else
            sed -i "s/sha256 \".*\"/sha256 \"$SHA256\"/" Formula/iris.rb
        fi
        echo -e "  ${GREEN}✓${NC} Updated Formula/iris.rb with SHA256"
        
        # Commit SHA256 update
        if git rev-parse --git-dir > /dev/null 2>&1; then
            git add Formula/iris.rb
            git commit --allow-empty -m "Update formula SHA256 for $NEW_VERSION" || echo -e "  ${YELLOW}⚠️  Commit failed${NC}"
            
            read -p "Push SHA256 update? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git push origin main || echo -e "  ${YELLOW}⚠️  Push failed${NC}"
            fi
        fi
    fi
else
    echo -e "  ${YELLOW}⚠️  Skipping SHA256 calculation (no git tag)${NC}"
fi

echo ""
echo -e "${CYAN}🍺 Step 5: Testing local installation...${NC}"

read -p "Test local installation? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    make install || {
        echo -e "  ${YELLOW}⚠️  Installation test failed${NC}"
        echo -e "  ${YELLOW}You can test manually later with: make install${NC}"
    }
fi

echo ""
echo -e "${CYAN}🚀 Step 6: Create GitHub Release...${NC}"

# Get repository name from git remote
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [[ -n "$REPO_URL" ]]; then
    # Extract owner/repo from various URL formats
    if [[ "$REPO_URL" =~ github.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
        REPO_OWNER="${BASH_REMATCH[1]}"
        REPO_NAME="${BASH_REMATCH[2]%.git}"
        FULL_REPO="$REPO_OWNER/$REPO_NAME"
    else
        FULL_REPO="mwangiiharun/iris"
    fi
else
    FULL_REPO="mwangiiharun/iris"
fi

if [[ "$PUSHED_TO_GITHUB" == "true" ]] && git rev-parse --git-dir > /dev/null 2>&1; then
    # Wait a moment for GitHub to process the tag
    echo "  Waiting 2 seconds for GitHub to process tag..."
    sleep 2
    
    # Check if GitHub CLI is available
    if command -v gh >/dev/null 2>&1; then
        echo "  Using GitHub CLI to create release..."
        read -p "Create GitHub release for $NEW_VERSION? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            RELEASE_NOTES="# 🚀 Iris $NEW_VERSION - The Messenger of Speed

## What's New

This release includes improvements and updates.

### 📦 Installation

\`\`\`bash
brew tap mwangiiharun/homebrew-iris
brew install iris
\`\`\`

### 📋 Usage

\`\`\`bash
iris              # Run speed test
iris --json       # JSON output
iris --history    # View history
iris --stats      # Statistics
\`\`\`

For more information, visit: https://github.com/$FULL_REPO"
            
            if gh release create "$NEW_VERSION" --title "$NEW_VERSION - The Messenger of Speed" --notes "$RELEASE_NOTES"; then
                echo -e "  ${GREEN}✓${NC} GitHub release created"
            else
                echo -e "  ${YELLOW}⚠️  Release creation failed. Creating via API...${NC}"
                # Fallback to API
                create_release_via_api=true
            fi
        fi
    else
        echo -e "  ${YELLOW}⚠️  GitHub CLI (gh) not found. Using API instead...${NC}"
        create_release_via_api=true
    fi
    
    # Fallback to API if CLI failed or not available
    if [[ "$create_release_via_api" == "true" ]]; then
        read -p "Create GitHub release via API for $NEW_VERSION? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "  Using GitHub API to create release..."
            # Check for GITHUB_TOKEN
            if [[ -n "$GITHUB_TOKEN" ]]; then
                RELEASE_DATA=$(cat <<EOF
{
  "tag_name": "$NEW_VERSION",
  "name": "$NEW_VERSION - The Messenger of Speed",
  "body": "## 🚀 Iris $NEW_VERSION - The Messenger of Speed\n\n### Installation\n\n\`\`\`bash\nbrew tap mwangiiharun/homebrew-iris\nbrew install iris\n\`\`\`\n\nFor more information, visit: https://github.com/$FULL_REPO",
  "draft": false,
  "prerelease": false
}
EOF
)
                RESPONSE=$(curl -s -X POST \
                    -H "Authorization: token $GITHUB_TOKEN" \
                    -H "Accept: application/vnd.github.v3+json" \
                    "https://api.github.com/repos/$FULL_REPO/releases" \
                    -d "$RELEASE_DATA")
                
                if echo "$RESPONSE" | grep -q '"id"'; then
                    echo -e "  ${GREEN}✓${NC} GitHub release created via API"
                else
                    echo -e "  ${YELLOW}⚠️  Release creation failed. Error:${NC}"
                    echo "$RESPONSE" | head -5
                    echo -e "  ${YELLOW}Create manually: https://github.com/$FULL_REPO/releases/new${NC}"
                fi
            else
                echo -e "  ${YELLOW}⚠️  GITHUB_TOKEN not set. Cannot create release via API.${NC}"
                echo -e "  ${YELLOW}Create manually: https://github.com/$FULL_REPO/releases/new${NC}"
                echo -e "  ${YELLOW}Or install GitHub CLI: brew install gh${NC}"
            fi
        fi
    fi
else
    echo -e "  ${YELLOW}⚠️  Skipping release creation (tag not pushed or not a git repo)${NC}"
fi

echo ""
echo -e "${CYAN}📦 Step 7: Update Homebrew tap (if exists)...${NC}"

TAP_DIR="$HOME/projects/homebrew-iris"
if [[ -d "$TAP_DIR" ]]; then
    read -p "Update tap repository at $TAP_DIR? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp Formula/iris.rb "$TAP_DIR/Formula/iris.rb"
        echo -e "  ${GREEN}✓${NC} Copied formula to tap"
        
        cd "$TAP_DIR"
        git add Formula/iris.rb
        git commit --allow-empty -m "Update iris to $NEW_VERSION" || echo -e "  ${YELLOW}⚠️  Commit failed${NC}"
        
        read -p "Push tap changes? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push origin main || {
                BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
                git push origin "$BRANCH" || echo -e "  ${YELLOW}⚠️  Push failed${NC}"
            }
            echo -e "  ${GREEN}✓${NC} Tap updated and pushed"
        fi
        cd - > /dev/null
    fi
else
    echo -e "  ${YELLOW}⚠️  Tap directory not found at $TAP_DIR${NC}"
    echo -e "  ${YELLOW}Set up tap with: ./scripts/setup-tap.sh${NC}"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ Version bump and deploy complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
echo ""
echo "Summary:"
echo "  Version: $CURRENT_VERSION → $NEW_VERSION"
echo "  Formula: Formula/iris.rb updated"
echo "  Git tag: $NEW_VERSION (if pushed)"
echo "  GitHub release: Created (if pushed)"
echo ""
echo "Users can install with:"
echo "  brew tap mwangiiharun/homebrew-iris"
echo "  brew install iris"
echo ""

