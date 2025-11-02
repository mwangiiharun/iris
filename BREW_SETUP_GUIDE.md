# Complete Homebrew Setup Guide - From Scratch

This guide walks you through setting up Homebrew distribution for Iris v5.2 from the beginning.

## Prerequisites

- ✅ Git repository on GitHub (https://github.com/mwangiiharun/iris)
- ✅ All code changes are ready
- ✅ Version number is set to 5.2

## Step-by-Step Process

### Step 1: Commit Current Changes

First, commit the fixes we just made:

```bash
cd /Users/mwangiiharun/projects/iris

# Check what's changed
git status

# Add the fixed files
git add bin/iris Formula/iris.rb

# Commit
git commit -m "Fix remaining hermes references - update help text and formula tests for v5.2"

# Push to GitHub
git push origin main
```

### Step 2: Create Git Tag v5.2

Create a git tag for version 5.2:

```bash
# Create the tag
git tag -a v5.2 -m "Release v5.2 - Fix hermes references, update help text"

# Push the tag to GitHub
git push origin v5.2
```

**Verify the tag:**
```bash
git tag -l
# Should show v5.2 in the list
```

### Step 3: Create GitHub Release

1. **Go to GitHub:**
   - Visit: https://github.com/mwangiiharun/iris/releases/new

2. **Fill in the release details:**
   - **Choose a tag:** Select `v5.2` (or create new tag v5.2)
   - **Release title:** `v5.2 - The Messenger of Speed`
   - **Description:** Copy from `RELEASE_NOTES_GITHUB.md` or use:
   
   ```
   ## Iris v5.2 - The Messenger of Speed
   
   ### Bug Fixes
   - Fixed remaining "hermes" references in help text
   - Updated Homebrew formula tests to check for "Iris" instead of "Hermes"
   
   ### Installation
   
   ```bash
   brew tap mwangiiharun/homebrew-iris
   brew install iris
   ```
   ```

3. **Publish the release:**
   - Click "Publish release"
   - GitHub will automatically create a tarball at: 
     `https://github.com/mwangiiharun/iris/archive/refs/tags/v5.2.tar.gz`

### Step 4: Calculate SHA256 Hash

After the GitHub release is created, calculate the SHA256:

```bash
# Run the calculation script
./scripts/calculate-sha256.sh v5.2

# OR manually:
curl -L https://github.com/mwangiiharun/iris/archive/refs/tags/v5.2.tar.gz | shasum -a 256
```

**Note:** The formula already has a SHA256 (`d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed`). Verify this matches the actual tarball!

### Step 5: Update Formula with Correct SHA256 (if needed)

If the SHA256 from Step 4 is different from what's in `Formula/iris.rb`:

```bash
# The calculate script can update it automatically, or manually:
# Edit Formula/iris.rb and update the sha256 line with the new value
```

### Step 6: Test Local Installation

Before setting up the tap, test the formula locally:

```bash
# Install from local formula
brew install --build-from-source Formula/iris.rb

# Verify installation
iris --version    # Should show "Iris v5.2 by Mwangii K"
iris --help       # Should show "iris" (not "hermes")
iris --json       # Test JSON output

# Run formula tests
brew test iris

# If everything works, you can uninstall to test from tap later:
# brew uninstall iris
```

### Step 7: Set Up Homebrew Tap Repository

Create a separate repository for the Homebrew tap:

#### 7a. Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `homebrew-iris` (must start with `homebrew-`)
3. Description: `Homebrew tap for Iris - The Messenger of Speed`
4. Make it Public (required for Homebrew)
5. **Don't** initialize with README, .gitignore, or license
6. Click "Create repository"

#### 7b. Set Up Tap Locally

Run the setup script:

```bash
./scripts/setup-tap.sh homebrew-iris mwangiiharun
```

This will:
- Create `~/projects/homebrew-iris` directory
- Copy `Formula/iris.rb` to the tap
- Set up git repository
- Create a README

#### 7c. Push to GitHub

If the script prompts you to push, say yes. Otherwise:

```bash
cd ~/projects/homebrew-iris

# Make sure we have the latest formula with correct SHA256
cp ../iris/Formula/iris.rb Formula/iris.rb

# Add and commit
git add .
git commit -m "Add Iris formula v5.2"

# Push to GitHub
git push -u origin main
```

### Step 8: Test Installation from Tap

Now test that users can install from your tap:

```bash
# Add your tap
brew tap mwangiiharun/homebrew-iris

# Install Iris
brew install iris

# Verify
iris --version
iris --help

# Test all features
iris --json
iris --history  # (if you have history)
iris --stats    # (if you have history)
```

### Step 9: Commit Formula Update (if SHA256 was updated)

If you updated the SHA256 in Step 5, commit that change:

```bash
cd /Users/mwangiiharun/projects/iris

git add Formula/iris.rb
git commit -m "Update formula SHA256 for v5.2 release"
git push origin main
```

Then also update the tap:

```bash
cd ~/projects/homebrew-iris
cp ../iris/Formula/iris.rb Formula/iris.rb
git add Formula/iris.rb
git commit -m "Update Iris to v5.2"
git push origin main
```

### Step 10: Verify Everything

Final checklist:

- [ ] Git tag v5.2 exists and is pushed
- [ ] GitHub release v5.2 is published
- [ ] SHA256 in formula matches the tarball
- [ ] Local installation works: `brew install --build-from-source Formula/iris.rb`
- [ ] Tap repository exists and formula is pushed
- [ ] Installation from tap works: `brew tap mwangiiharun/homebrew-iris && brew install iris`
- [ ] All commands work: `iris --version`, `iris --help`, `iris --json`

## Users Can Now Install

Share this with users:

```bash
brew tap mwangiiharun/homebrew-iris
brew install iris
```

Or update existing installations:

```bash
brew upgrade iris
```

## Troubleshooting

### "SHA256 mismatch" error
- Recalculate SHA256 after the GitHub release is created
- Make sure the tag v5.2 exists and release is published
- Update both `Formula/iris.rb` in main repo and tap repo

### "No such file or directory" errors
- Verify the release tarball URL is accessible:
  ```bash
  curl -I https://github.com/mwangiiharun/iris/archive/refs/tags/v5.2.tar.gz
  ```
- Make sure the tag exists: `git tag -l`

### "Formula not found" in tap
- Make sure tap repository name starts with `homebrew-`
- Verify the formula file is at `Formula/iris.rb` in the tap repo
- Check the tap is added: `brew tap`

### Test failures
- Run `iris --version` manually to see what it outputs
- Make sure the test assertions in the formula match the actual output

## Next Release Workflow

For future releases (v5.3, etc.):

1. Update version in `bin/iris` and `version` file
2. Update `Formula/iris.rb` version and URL
3. Commit changes
4. Create git tag
5. Create GitHub release
6. Calculate SHA256
7. Update formula SHA256
8. Update tap repository
9. Test installation

