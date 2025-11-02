#!/bin/bash
# Helper script to set up a Homebrew tap for Iris (renamed from Iris)

set -e

# Project directories
PROJECTS_DIR="$HOME/projects"
HERMES_DIR="$PROJECTS_DIR/iris"
TAP_NAME="${1:-homebrew-tap}"
TAP_DIR="$PROJECTS_DIR/$TAP_NAME"
GITHUB_USER="${2:-mwangiiharun}"
FORMULA_NAME="${3:-iris}"

echo "🚀 Setting up Homebrew tap: $TAP_NAME"
echo "   Tap directory: $TAP_DIR"
echo "   Formula name: $FORMULA_NAME"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is required"
    exit 1
fi

# Create tap directory structure
echo "📁 Creating tap directory structure..."
mkdir -p "$TAP_DIR/Formula"
cd "$TAP_DIR"

# Initialize git repo if not already
if [ ! -d ".git" ]; then
    echo "📦 Initializing git repository..."
    git init
fi

# Copy formula
echo "📋 Copying formula..."
if [ -f "$HERMES_DIR/Formula/${FORMULA_NAME}.rb" ]; then
    cp "$HERMES_DIR/Formula/${FORMULA_NAME}.rb" "Formula/${FORMULA_NAME}.rb"
    echo "   ✓ Copied Formula/${FORMULA_NAME}.rb"
elif [ -f "$HERMES_DIR/Formula/iris.rb" ]; then
    cp "$HERMES_DIR/Formula/iris.rb" "Formula/${FORMULA_NAME}.rb"
    echo "   ⚠️  Copied iris.rb as ${FORMULA_NAME}.rb - will need manual update"
else
    echo "   ❌ No formula file found in $HERMES_DIR/Formula/"
    exit 1
fi

# Create README for tap
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

echo ""
echo "✅ Tap setup complete!"
echo ""

# Check if remote exists
REMOTE_URL="git@github.com:$GITHUB_USER/$TAP_NAME.git"
if git remote get-url origin >/dev/null 2>&1; then
    CURRENT_REMOTE=$(git remote get-url origin)
    if [[ "$CURRENT_REMOTE" != "$REMOTE_URL" ]]; then
        echo "⚠️  Remote 'origin' exists but points to: $CURRENT_REMOTE"
        read -p "Update to $REMOTE_URL? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git remote set-url origin "$REMOTE_URL"
            echo "   ✓ Remote updated"
        fi
    else
        echo "✓ Remote already configured correctly"
    fi
else
    echo "📡 Setting up git remote..."
    git remote add origin "$REMOTE_URL" 2>/dev/null || {
        echo "   ⚠️  Remote might already exist"
    }
    echo "   ✓ Remote configured"
fi

echo ""
read -p "Do you want to commit and push to GitHub now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "📤 Committing and pushing to GitHub..."
    
    # Add all files
    git add .
    
    # Check if there are changes
    if [[ -n $(git status --porcelain) ]] || [[ -z $(git log -1 2>/dev/null) ]]; then
        # Commit
        git commit -m "Initial tap setup for Iris" || {
            echo "   ⚠️  Nothing to commit or commit failed"
        }
        
        # Push
        echo "   Pushing to origin..."
        git push -u origin main 2>/dev/null || {
            BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
            echo "   Trying branch: $BRANCH"
            git push -u origin "$BRANCH" || {
                echo -e "${YELLOW}   ⚠️  Push failed. Make sure:${NC}"
                echo "      - GitHub repository '$TAP_NAME' exists"
                echo "      - You have push access"
                echo "      - SSH keys are configured"
                echo ""
                echo "   You can push manually:"
                echo "   cd $TAP_DIR"
                echo "   git push -u origin main"
            }
        }
        echo "   ✓ Pushed to GitHub"
    else
        echo "   ✓ Nothing to commit"
    fi
    
    echo ""
    echo "✅ Tap setup and push complete!"
    echo ""
    echo "Install from tap:"
    echo "   brew tap $GITHUB_USER/$TAP_NAME"
    echo "   brew install $FORMULA_NAME"
else
    echo ""
    echo "Next steps:"
    echo "1. Create GitHub repository: $TAP_NAME"
    echo ""
    echo "2. Push to GitHub:"
    echo "   cd $TAP_DIR"
    echo "   git remote add origin git@github.com:$GITHUB_USER/$TAP_NAME.git"
    echo "   git add ."
    echo "   git commit -m 'Initial tap setup for Iris'"
    echo "   git push -u origin main"
    echo ""
    echo "3. Calculate SHA256:"
    echo "   cd $HERMES_DIR && ./scripts/calculate-sha256.sh v5.2 $FORMULA_NAME"
    echo ""
    echo "4. Update Formula/${FORMULA_NAME}.rb with SHA256"
    echo ""
    echo "5. Install from tap:"
    echo "   brew tap $GITHUB_USER/$TAP_NAME"
    echo "   brew install $FORMULA_NAME"
fi
echo ""

