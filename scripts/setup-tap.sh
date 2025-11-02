#!/bin/bash
# Helper script to set up a Homebrew tap for Hermes

set -e

TAP_NAME="${1:-homebrew-hermes}"
GITHUB_USER="${2:-mwangiiharun}"

echo "🚀 Setting up Homebrew tap: $TAP_NAME"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is required"
    exit 1
fi

# Create tap directory structure
echo "📁 Creating tap directory structure..."
mkdir -p "../$TAP_NAME/Formula"
cd "../$TAP_NAME"

# Initialize git repo if not already
if [ ! -d ".git" ]; then
    echo "📦 Initializing git repository..."
    git init
fi

# Copy formula
echo "📋 Copying formula..."
cp "../hermes/Formula/hermes.rb" "Formula/hermes.rb"

# Create README for tap
cat > README.md << EOF
# homebrew-hermes

Homebrew tap for Hermes - The Messenger of Speed

## Installation

\`\`\`bash
brew tap $GITHUB_USER/$TAP_NAME
brew install hermes
\`\`\`

## Updating

\`\`\`bash
brew upgrade hermes
\`\`\`

For more information, visit: https://github.com/$GITHUB_USER/hermes
EOF

echo ""
echo "✅ Tap setup complete!"
echo ""
echo "Next steps:"
echo "1. Calculate SHA256 for release tarball:"
echo "   cd ../hermes && make sha256"
echo ""
echo "2. Update Formula/hermes.rb with the SHA256 value"
echo ""
echo "3. Create GitHub repository: $TAP_NAME"
echo ""
echo "4. Push to GitHub:"
echo "   cd ../$TAP_NAME"
echo "   git remote add origin git@github.com:$GITHUB_USER/$TAP_NAME.git"
echo "   git add ."
echo "   git commit -m 'Initial tap setup'"
echo "   git push -u origin main"
echo ""
echo "5. Install from tap:"
echo "   brew tap $GITHUB_USER/$TAP_NAME"
echo "   brew install hermes"

