#!/bin/bash
# Script to rename Iris to Iris while keeping repository name

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

echo "🔄 Renaming Iris to Iris..."
echo "   Working directory: $HERMES_DIR"
echo "   Tap directory: $TAP_DIR"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Backup confirmation
echo -e "${YELLOW}⚠️  This will rename all references from 'iris' to 'iris'${NC}"
echo "   (Repository name will remain 'iris')"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

# Step 1: Rename binary
echo -e "${GREEN}📦 Step 1: Renaming binary...${NC}"
if [ -f "bin/iris" ]; then
    mv bin/iris bin/iris
    echo "   ✓ Renamed bin/iris -> bin/iris"
else
    echo "   ⚠️  bin/iris not found, skipping"
fi

# Step 2: Update binary content
echo -e "${GREEN}📝 Step 2: Updating binary content...${NC}"
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
    echo "   ✓ Updated script content"
fi

# Step 3: Update Formula
echo -e "${GREEN}🍺 Step 3: Updating Homebrew formula...${NC}"
if [ -f "Formula/iris.rb" ]; then
    # Create iris.rb from iris.rb
    sed -e 's/class Iris/class Iris/g' \
        -e 's/desc "⚡ Iris/desc "⚡ Iris/g' \
        -e 's/iris\.rb/iris.rb/g' \
        -e 's/"iris"/"iris"/g' \
        -e 's/#{bin}\/iris/#{bin}\/iris/g' \
        Formula/iris.rb > Formula/iris.rb
    
    # Update references in iris.rb but keep repo URLs
    sed -i '' 's/homepage "https:\/\/github.com\/mwangiiharun\/iris"/homepage "https:\/\/github.com\/mwangiiharun\/iris"/' Formula/iris.rb
    sed -i '' 's/url "https:\/\/github.com\/mwangiiharun\/iris/url "https:\/\/github.com\/mwangiiharun\/iris/g' Formula/iris.rb
    sed -i '' 's/bin\/iris/bin\/iris/g' Formula/iris.rb
    
    echo "   ✓ Created Formula/iris.rb"
    # Keep iris.rb for reference, but we'll use iris.rb
fi

# Step 4: Update version file
echo -e "${GREEN}📌 Step 4: Updating version files...${NC}"
# Version file is fine as is

# Step 5: Update Makefile
echo -e "${GREEN}🔧 Step 5: Updating Makefile...${NC}"
if [ -f "Makefile" ]; then
    sed -i '' 's/iris/iris/g' Makefile
    sed -i '' 's/Iris/Iris/g' Makefile
    echo "   ✓ Updated Makefile"
fi

# Step 6: Update README.md
echo -e "${GREEN}📚 Step 6: Updating README.md...${NC}"
if [ -f "README.md" ]; then
    # Update all references but keep repo URLs
    sed -i '' 's/Iris/Iris/g' README.md
    sed -i '' 's/iris/iris/g' README.md
    # Fix repo URLs back to iris
    sed -i '' 's|github.com/mwangiiharun/hermes|github.com/mwangiiharun/hermes|g' README.md
    echo "   ✓ Updated README.md"
fi

# Step 7: Update other documentation files
echo -e "${GREEN}📄 Step 7: Updating documentation...${NC}"
for file in INSTALL.md HOMEBREW_SETUP.md RELEASE_CHECKLIST.md RELEASE_NOTES*.md; do
    if [ -f "$file" ]; then
        sed -i '' 's/Iris/Iris/g' "$file"
        sed -i '' 's/iris/iris/g' "$file"
        # Fix repo URLs back to iris
        sed -i '' 's|github.com/mwangiiharun/hermes|github.com/mwangiiharun/hermes|g' "$file"
        echo "   ✓ Updated $file"
    fi
done

# Step 8: Update scripts
echo -e "${GREEN}🔨 Step 8: Updating helper scripts...${NC}"
if [ -f "scripts/calculate-sha256.sh" ]; then
    sed -i '' 's/iris/iris/g' scripts/calculate-sha256.sh
    sed -i '' 's|github.com/mwangiiharun/hermes|github.com/mwangiiharun/hermes|g' scripts/calculate-sha256.sh
    echo "   ✓ Updated scripts/calculate-sha256.sh"
fi

if [ -f "scripts/setup-tap.sh" ]; then
    sed -i '' 's/iris/iris/g' scripts/setup-tap.sh
    sed -i '' 's/Iris/Iris/g' scripts/setup-tap.sh
    # Keep repo references as iris
    sed -i '' 's|github.com/mwangiiharun/hermes|github.com/mwangiiharun/hermes|g' scripts/setup-tap.sh
    echo "   ✓ Updated scripts/setup-tap.sh"
fi

# Step 9: Update .gitignore
echo -e "${GREEN}🚫 Step 9: Updating .gitignore...${NC}"
if [ -f ".gitignore" ]; then
    sed -i '' 's/iris/iris/g' .gitignore
    echo "   ✓ Updated .gitignore"
fi

# Step 10: Update GitHub workflow
echo -e "${GREEN}⚙️  Step 10: Updating GitHub workflow...${NC}"
if [ -f ".github/workflows/homebrew.yml" ]; then
    sed -i '' 's/iris/iris/g' .github/workflows/homebrew.yml
    sed -i '' 's/Iris/Iris/g' .github/workflows/homebrew.yml
    # Keep repo reference
    sed -i '' 's|github.repository.*iris|github.repository|g' .github/workflows/homebrew.yml
    echo "   ✓ Updated GitHub workflow"
fi

echo ""
echo -e "${GREEN}✅ Renaming complete!${NC}"
echo ""
echo "📋 Summary of changes:"
echo "   • Binary: bin/iris -> bin/iris"
echo "   • Formula: Formula/iris.rb -> Formula/iris.rb"
echo "   • All references: iris -> iris"
echo "   • Repository URLs: kept as 'iris'"
echo "   • Tap directory: $TAP_DIR"
echo ""
echo ""
echo "📝 Next steps:"
echo ""
read -p "Do you want to commit and push changes now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${GREEN}📤 Committing and pushing to git...${NC}"
    
    # Check if there are changes to commit
    if [[ -n $(git status --porcelain) ]]; then
        echo "   Adding all changes..."
        git add .
        echo "   Committing..."
        git commit -m "Rename Iris to Iris" || {
            echo -e "${YELLOW}   ⚠️  Commit failed (maybe no changes?)${NC}"
        }
        
        # Push to main branch
        echo "   Pushing to origin main..."
        git push origin main || {
            BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
            echo "   Trying branch: $BRANCH"
            git push origin "$BRANCH" || {
                echo -e "${YELLOW}   ⚠️  Push failed. You can push manually later.${NC}"
            }
        }
        echo "   ✓ Changes pushed"
    else
        echo "   ✓ No changes to commit"
    fi
    
    echo ""
    echo "Next: Run ./scripts/prepare-release.sh v5.2"
else
    echo ""
    echo "Manual steps:"
    echo "   1. Review changes: git diff"
    echo "   2. Test the binary: ./bin/iris --version"
    echo "   3. Commit: git add . && git commit -m 'Rename Iris to Iris'"
    echo "   4. Push: git push origin main"
    echo "   5. Run: ./scripts/prepare-release.sh v5.2"
fi
echo ""

