#!/bin/bash
# Complete migration script: Rename Hermes to Iris, create new repos, and clean up
# Can be run from anywhere

set -e

# Get the script's directory (wherever it's located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Project directories
PROJECTS_DIR="$HOME/projects"
OLD_PROJECT_DIR="$PROJECTS_DIR/hermes"
NEW_PROJECT_DIR="$PROJECTS_DIR/iris"
OLD_TAP_DIR="$PROJECTS_DIR/homebrew-hermes"
NEW_TAP_DIR="$PROJECTS_DIR/homebrew-iris"

GITHUB_USER="${GITHUB_USER:-mwangiiharun}"
OLD_REPO="hermes"
NEW_REPO="iris"
OLD_TAP_REPO="homebrew-hermes"
NEW_TAP_REPO="homebrew-iris"
FORMULA_NAME="iris"

# Default version
VERSION="${1:-v5.2}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  🚀 Complete Migration: Hermes → Iris${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo ""
echo "Script location: $SCRIPT_DIR"
echo "Working from: $(pwd)"
echo ""
echo "This script will:"
echo "  1. Rename project directory: hermes → iris"
echo "  2. Update all references in code"
echo "  3. Create new GitHub repositories (main + tap)"
echo "  4. Set up Homebrew tap with formula"
echo "  5. Create GitHub Actions workflow"
echo "  6. Set up and push to new repos"
echo "  7. Remove old repositories (optional)"
echo ""
echo "Directories:"
echo "  Old project: $OLD_PROJECT_DIR"
echo "  New project: $NEW_PROJECT_DIR"
echo "  Old tap: $OLD_TAP_DIR"
echo "  New tap: $NEW_TAP_DIR"
echo ""

# Verify directories exist
if [ ! -d "$OLD_PROJECT_DIR" ] && [ ! -d "$NEW_PROJECT_DIR" ]; then
    echo -e "${RED}❌ Error: Neither $OLD_PROJECT_DIR nor $NEW_PROJECT_DIR found!${NC}"
    echo "   Please ensure the project directory exists."
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is required but not installed.${NC}"
    echo "   Install it: brew install gh"
    exit 1
fi

# Check if user is logged into gh
if ! gh auth status &>/dev/null; then
    echo -e "${RED}❌ Error: Not logged into GitHub CLI.${NC}"
    echo "   Run: gh auth login"
    exit 1
fi

read -p "Continue with migration? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

# ============================================================
# STEP 1: Rename Project Directory
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Step 1: Renaming Project Directory${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

if [ -d "$NEW_PROJECT_DIR" ]; then
    echo -e "${YELLOW}⚠${NC}  $NEW_PROJECT_DIR already exists. Using existing directory."
    CURRENT_DIR="$NEW_PROJECT_DIR"
elif [ -d "$OLD_PROJECT_DIR" ]; then
    echo "   Renaming $OLD_PROJECT_DIR → $NEW_PROJECT_DIR"
    mv "$OLD_PROJECT_DIR" "$NEW_PROJECT_DIR"
    echo -e "${GREEN}✓${NC} Directory renamed"
    CURRENT_DIR="$NEW_PROJECT_DIR"
else
    echo -e "${RED}❌${NC} Neither $OLD_PROJECT_DIR nor $NEW_PROJECT_DIR found!"
    exit 1
fi

# Change to project directory (absolute path)
cd "$CURRENT_DIR" || {
    echo -e "${RED}❌${NC} Failed to change to $CURRENT_DIR"
    exit 1
}
echo "   Working in: $(pwd)"

# ============================================================
# STEP 2: Rename Binary and Update Code
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Step 2: Updating Code References${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

# Rename binary if needed
if [ -f "bin/hermes" ] && [ ! -f "bin/iris" ]; then
    mv bin/hermes bin/iris
    echo -e "${GREEN}✓${NC} Renamed bin/hermes → bin/iris"
elif [ -f "bin/iris" ]; then
    echo -e "${GREEN}✓${NC} bin/iris already exists"
else
    echo -e "${RED}❌${NC} Binary not found!"
    exit 1
fi

# Update binary content if needed (check for any hermes references)
if [ -f "bin/iris" ]; then
    if grep -q "Hermes\|hermes" bin/iris 2>/dev/null; then
        sed -i '' 's/Hermes/Iris/g' bin/iris
        sed -i '' 's/HERMES/IRIS/g' bin/iris
        sed -i '' 's/hermes_history/iris_history/g' bin/iris
        sed -i '' 's/hermes_realtime/iris_realtime/g' bin/iris
        sed -i '' 's/# ⚡ Hermes/# ⚡ Iris/g' bin/iris
        sed -i '' 's/⚡ Hermes/⚡ Iris/g' bin/iris
        sed -i '' 's/log_file="\$HOME\/.hermes_history"/log_file="$HOME\/.iris_history"/' bin/iris
        sed -i '' 's/tmp_file="\/tmp\/hermes_realtime.json"/tmp_file="\/tmp\/iris_realtime.json"/' bin/iris
        echo -e "${GREEN}✓${NC} Updated binary content"
    else
        echo -e "${GREEN}✓${NC} Binary already updated"
    fi
fi

# Update Formula
if [ -f "Formula/hermes.rb" ] && [ ! -f "Formula/iris.rb" ]; then
    sed -e 's/class Hermes/class Iris/g' \
        -e 's/desc "⚡ Hermes/desc "⚡ Iris/g' \
        -e 's/"hermes"/"iris"/g' \
        -e 's/#{bin}\/hermes/#{bin}\/iris/g' \
        -e 's/bin\/hermes/bin\/iris/g' \
        Formula/hermes.rb > Formula/iris.rb
    echo -e "${GREEN}✓${NC} Created Formula/iris.rb"
elif [ -f "Formula/iris.rb" ]; then
    echo -e "${GREEN}✓${NC} Formula/iris.rb already exists"
fi

# Update version in files
if [ -f "bin/iris" ]; then
    CURRENT_VERSION=$(grep -E '^VERSION=' bin/iris | head -1 | cut -d'"' -f2)
    if [ "$CURRENT_VERSION" != "$VERSION" ]; then
        sed -i '' "s/VERSION=\"$CURRENT_VERSION\"/VERSION=\"$VERSION\"/" bin/iris
        sed -i '' "s/# ⚡ Iris.*(v.*)/# ⚡ Iris — The Messenger of Speed ($VERSION)/" bin/iris
        echo -e "${GREEN}✓${NC} Updated version in binary"
    fi
fi

VERSION_NUM=$(echo $VERSION | sed 's/v//')
echo "$VERSION_NUM" > version

if [ -f "Formula/iris.rb" ]; then
    sed -i '' "s/version \"[^\"]*\"/version \"$VERSION_NUM\"/" Formula/iris.rb
    sed -i '' "s|url \".*hermes.*\"|url \"https://github.com/$GITHUB_USER/$NEW_REPO/archive/refs/tags/$VERSION.tar.gz\"|" Formula/iris.rb
    sed -i '' "s|homepage \".*hermes.*\"|homepage \"https://github.com/$GITHUB_USER/$NEW_REPO\"|" Formula/iris.rb
    echo -e "${GREEN}✓${NC} Updated formula"
fi

# Update GitHub workflow if it exists
if [ -f ".github/workflows/homebrew.yml" ]; then
    sed -i '' "s/hermes/iris/g" .github/workflows/homebrew.yml 2>/dev/null || true
    sed -i '' "s/Hermes/Iris/g" .github/workflows/homebrew.yml 2>/dev/null || true
    sed -i '' "s|github.com/$GITHUB_USER/hermes|github.com/$GITHUB_USER/iris|g" .github/workflows/homebrew.yml 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Updated GitHub workflow"
fi

# Update all documentation files (skip if already updated)
echo "   Checking documentation files..."
for file in README.md INSTALL.md HOMEBREW_SETUP.md RELEASE_CHECKLIST.md RELEASE_NOTES*.md Makefile .gitignore; do
    if [ -f "$file" ] && grep -q "hermes\|Hermes" "$file" 2>/dev/null; then
        sed -i '' 's/Hermes/Iris/g' "$file" 2>/dev/null || true
        sed -i '' 's/hermes/iris/g' "$file" 2>/dev/null || true
        sed -i '' "s|github.com/$GITHUB_USER/hermes|github.com/$GITHUB_USER/iris|g" "$file" 2>/dev/null || true
        echo "   ✓ Updated $file"
    fi
done

echo -e "${GREEN}✓${NC} Step 2 complete"

# ============================================================
# STEP 3: Calculate SHA256 (if tag exists)
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Step 3: Calculating SHA256${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

URL="https://github.com/$GITHUB_USER/$NEW_REPO/archive/refs/tags/$VERSION.tar.gz"
SHA256=""

echo "   Checking if tag exists..."
if curl -sL --head "$URL" | head -n 1 | grep -q "200 OK"; then
    echo "   Fetching tarball..."
    SHA256=$(curl -sL "$URL" | shasum -a 256 | cut -d' ' -f1)
    echo -e "${GREEN}✓${NC} SHA256: $SHA256"
    
    if [ -f "Formula/iris.rb" ]; then
        sed -i '' "s/sha256 \".*\"/sha256 \"$SHA256\"/" Formula/iris.rb
        echo -e "${GREEN}✓${NC} Updated formula with SHA256"
    fi
else
    echo -e "${YELLOW}⚠${NC}  Tag doesn't exist yet. Will update SHA256 after tag is created."
    SHA256="REPLACE_WITH_REAL_SHA256"
fi

# ============================================================
# STEP 4: Create GitHub Repositories
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Step 4: Creating GitHub Repositories${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

# Create main repository
echo "   Creating repository: $NEW_REPO"
if gh repo view "$GITHUB_USER/$NEW_REPO" &>/dev/null; then
    echo -e "${YELLOW}⚠${NC}  Repository $GITHUB_USER/$NEW_REPO already exists"
else
    gh repo create "$GITHUB_USER/$NEW_REPO" --public --description "⚡ Iris — The Messenger of Speed - Beautiful terminal speed test tool" --clone=false
    echo -e "${GREEN}✓${NC} Created repository: $GITHUB_USER/$NEW_REPO"
fi

# Create tap repository
echo "   Creating repository: $NEW_TAP_REPO"
if gh repo view "$GITHUB_USER/$NEW_TAP_REPO" &>/dev/null; then
    echo -e "${YELLOW}⚠${NC}  Repository $GITHUB_USER/$NEW_TAP_REPO already exists"
else
    gh repo create "$GITHUB_USER/$NEW_TAP_REPO" --public --description "Homebrew tap for Iris" --clone=false
    echo -e "${GREEN}✓${NC} Created repository: $GITHUB_USER/$NEW_TAP_REPO"
fi

# ============================================================
# STEP 5: Set Up Git Remotes and Push Main Repo
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Step 5: Setting Up Git and Pushing Main Repo${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

# Main repository
cd "$CURRENT_DIR"

# Remove old remote if it exists
if git remote get-url origin 2>/dev/null | grep -q "hermes"; then
    git remote remove origin 2>/dev/null || true
fi

# Add new remote
NEW_REMOTE="git@github.com:$GITHUB_USER/$NEW_REPO.git"
if ! git remote get-url origin &>/dev/null || [ "$(git remote get-url origin)" != "$NEW_REMOTE" ]; then
    git remote add origin "$NEW_REMOTE" 2>/dev/null || git remote set-url origin "$NEW_REMOTE"
    echo -e "${GREEN}✓${NC} Configured git remote"
fi

# Commit changes
if [[ -n $(git status --porcelain) ]]; then
    git add .
    git commit -m "Rename Hermes to Iris and prepare $VERSION release" || echo "   No changes to commit"
fi

# Push to new repo
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
echo "   Pushing to $GITHUB_USER/$NEW_REPO..."
git push -u origin "$BRANCH" || {
    echo -e "${YELLOW}⚠${NC}  Push failed. You may need to push manually."
}

# Create and push tag
if ! git rev-parse "$VERSION" >/dev/null 2>&1; then
    git tag "$VERSION"
    git push origin "$VERSION" || echo -e "${YELLOW}⚠${NC}  Tag push failed"
    echo -e "${GREEN}✓${NC} Created and pushed tag $VERSION"
    
    # Recalculate SHA256 if tag was just created
    if [ "$SHA256" = "REPLACE_WITH_REAL_SHA256" ]; then
        sleep 2  # Wait for GitHub to process
        SHA256=$(curl -sL "$URL" | shasum -a 256 | cut -d' ' -f1)
        if [ -f "Formula/iris.rb" ]; then
            sed -i '' "s/sha256 \".*\"/sha256 \"$SHA256\"/" Formula/iris.rb
            git add Formula/iris.rb
            git commit -m "Update SHA256 for $VERSION" || true
            git push origin "$BRANCH" || true
        fi
    fi
else
    echo -e "${GREEN}✓${NC} Tag $VERSION already exists"
fi

# ============================================================
# STEP 6: Set Up Homebrew Tap Repository (Complete Setup)
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Step 6: Setting Up Homebrew Tap${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

# Create tap directory structure
mkdir -p "$NEW_TAP_DIR/Formula"
cd "$NEW_TAP_DIR"

# Initialize git if needed
if [ ! -d ".git" ]; then
    git init
    git branch -M main 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Initialized git repository"
fi

# Copy formula
if [ -f "$CURRENT_DIR/Formula/iris.rb" ]; then
    cp "$CURRENT_DIR/Formula/iris.rb" "Formula/iris.rb"
    echo -e "${GREEN}✓${NC} Copied formula"
else
    echo -e "${RED}❌${NC} Formula not found in project!"
    exit 1
fi

# Create README
cat > README.md << EOF
# $NEW_TAP_REPO

Homebrew tap for Iris - The Messenger of Speed

## Installation

\`\`\`bash
brew tap $GITHUB_USER/$NEW_TAP_REPO
brew install $FORMULA_NAME
\`\`\`

## Updating

\`\`\`bash
brew upgrade $FORMULA_NAME
\`\`\`

For more information, visit: https://github.com/$GITHUB_USER/$NEW_REPO
EOF
echo -e "${GREEN}✓${NC} Created README.md"

# Create GitHub Actions workflow for automatic updates
mkdir -p ".github/workflows"
cat > ".github/workflows/update-formula.yml" << EOF
name: Update Formula

on:
  repository_dispatch:
    types: [update-formula]
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to update (e.g., v5.2)'
        required: true

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout tap
        uses: actions/checkout@v3
        with:
          token: \${{ secrets.GITHUB_TOKEN }}

      - name: Calculate SHA256
        id: sha256
        run: |
          VERSION="\${{ github.event.inputs.version || github.event.client_payload.version }}"
          if [ -z "\$VERSION" ]; then
            echo "Error: Version not provided"
            exit 1
          fi
          SHA256=\$(curl -sL "https://github.com/$GITHUB_USER/$NEW_REPO/archive/refs/tags/\${VERSION}.tar.gz" | shasum -a 256 | cut -d' ' -f1)
          echo "sha256=\$SHA256" >> \$GITHUB_OUTPUT
          echo "version=\$VERSION" >> \$GITHUB_OUTPUT

      - name: Update Formula
        run: |
          VERSION="\${{ steps.sha256.outputs.version }}"
          SHA256="\${{ steps.sha256.outputs.sha256 }}"
          VERSION_NUM=\$(echo \$VERSION | sed 's/v//')
          
          # Update version
          sed -i "s/version \".*\"/version \"\$VERSION_NUM\"/" Formula/${FORMULA_NAME}.rb
          
          # Update URL
          sed -i "s|url \".*\"|url \"https://github.com/$GITHUB_USER/$NEW_REPO/archive/refs/tags/\${VERSION}.tar.gz\"|" Formula/${FORMULA_NAME}.rb
          
          # Update SHA256
          sed -i "s/sha256 \".*\"/sha256 \"\$SHA256\"/" Formula/${FORMULA_NAME}.rb

      - name: Commit and push
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add Formula/${FORMULA_NAME}.rb
          git commit -m "Update ${FORMULA_NAME} to \${{ steps.sha256.outputs.version }}" || exit 0
          git push
EOF
echo -e "${GREEN}✓${NC} Created GitHub Actions workflow"

# Set up git remote
TAP_REMOTE="git@github.com:$GITHUB_USER/$NEW_TAP_REPO.git"
if ! git remote get-url origin &>/dev/null || [ "$(git remote get-url origin)" != "$TAP_REMOTE" ]; then
    git remote remove origin 2>/dev/null || true
    git remote add origin "$TAP_REMOTE"
    echo -e "${GREEN}✓${NC} Configured tap remote"
fi

# Commit and push tap
git add .
if [[ -n $(git status --porcelain) ]]; then
    git commit -m "Initial tap setup for Iris $VERSION" || echo "   No changes to commit"
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
echo "   Pushing tap to $GITHUB_USER/$NEW_TAP_REPO..."
git push -u origin "$BRANCH" || {
    echo -e "${YELLOW}⚠${NC}  Tap push failed. You may need to push manually."
}

echo -e "${GREEN}✓${NC} Step 6 complete"

# ============================================================
# STEP 7: Cleanup Old Repositories (Optional)
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Step 7: Cleanup Old Repositories${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

read -p "Do you want to delete old GitHub repositories? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Delete old main repo
    if gh repo view "$GITHUB_USER/$OLD_REPO" &>/dev/null; then
        echo "   Deleting $GITHUB_USER/$OLD_REPO..."
        gh repo delete "$GITHUB_USER/$OLD_REPO" --yes || {
            echo -e "${YELLOW}⚠${NC}  Failed to delete $OLD_REPO (may not exist or insufficient permissions)"
        }
    else
        echo "   $OLD_REPO doesn't exist, skipping"
    fi
    
    # Delete old tap repo
    if gh repo view "$GITHUB_USER/$OLD_TAP_REPO" &>/dev/null; then
        echo "   Deleting $GITHUB_USER/$OLD_TAP_REPO..."
        gh repo delete "$GITHUB_USER/$OLD_TAP_REPO" --yes || {
            echo -e "${YELLOW}⚠${NC}  Failed to delete $OLD_TAP_REPO (may not exist or insufficient permissions)"
        }
    else
        echo "   $OLD_TAP_REPO doesn't exist, skipping"
    fi
    
    # Remove old local directories (if empty or safe to remove)
    read -p "Remove old local directories? ($OLD_PROJECT_DIR, $OLD_TAP_DIR) (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -d "$OLD_PROJECT_DIR" ] && [ "$OLD_PROJECT_DIR" != "$CURRENT_DIR" ]; then
            rm -rf "$OLD_PROJECT_DIR"
            echo -e "${GREEN}✓${NC} Removed $OLD_PROJECT_DIR"
        fi
        if [ -d "$OLD_TAP_DIR" ]; then
            rm -rf "$OLD_TAP_DIR"
            echo -e "${GREEN}✓${NC} Removed $OLD_TAP_DIR"
        fi
    fi
else
    echo "   Skipping cleanup"
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  ✅ Migration Complete!${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo ""
echo "📋 Summary:"
echo "  Project: $CURRENT_DIR"
echo "  Tap: $NEW_TAP_DIR"
echo "  Version: $VERSION"
echo "  SHA256: ${SHA256:0:20}..."
echo ""
echo "🔗 Repositories:"
echo "  Main: https://github.com/$GITHUB_USER/$NEW_REPO"
echo "  Tap: https://github.com/$GITHUB_USER/$NEW_TAP_REPO"
echo ""
echo "📦 Installation:"
echo "  brew tap $GITHUB_USER/$NEW_TAP_REPO"
echo "  brew install $FORMULA_NAME"
echo ""
echo "🔄 Automated Updates:"
echo "  The tap repository includes a GitHub Actions workflow"
echo "  that can automatically update the formula when triggered."
echo ""
echo -e "${GREEN}✅ All done!${NC}"
echo ""

