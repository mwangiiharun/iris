# Release Checklist for Homebrew

## Pre-Release Steps

- [ ] All code changes committed and pushed
- [ ] Tests pass (`make test` or `iris --version`)
- [ ] README.md is up to date
- [ ] Version number updated in:
  - [ ] `bin/iris` (VERSION variable)
  - [ ] `version` file
  - [ ] `Formula/iris.rb` (version and url)

## Create Release

1. **Commit any remaining changes:**
   ```bash
   git add .
   git commit -m "Prepare for release v5.1"
   git push origin main
   ```

2. **Create and push git tag:**
   ```bash
   git tag v5.1
   git push origin v5.1
   ```

3. **Create GitHub Release:**
   - Go to: https://github.com/mwangiiharun/hermes/releases/new
   - Select tag: `v5.1`
   - Title: `v5.1 - The Messenger of Speed`
   - Description: Add release notes
   - GitHub will auto-generate a tarball

## Update Homebrew Formula

1. **Calculate SHA256:**
   ```bash
   ./scripts/calculate-sha256.sh v5.1
   ```

2. **Update Formula/iris.rb:**
   - Replace `REPLACE_WITH_REAL_SHA256` with the calculated SHA256
   - Verify version matches: `version "5.1"`
   - Verify URL points to correct tag

3. **Commit formula update:**
   ```bash
   git add Formula/iris.rb
   git commit -m "Update formula SHA256 for v5.1"
   git push origin main
   ```

## Set Up Homebrew Tap (First Time Only)

1. **Create tap repository on GitHub:**
   - Create new repo: `homebrew-iris` (or `homebrew-tap`)

2. **Set up tap structure:**
   ```bash
   ./scripts/setup-tap.sh homebrew-iris mwangiiharun
   cd ../homebrew-iris
   ```

3. **Update formula with SHA256:**
   - Copy updated `Formula/iris.rb` from main repo
   - Make sure SHA256 is correct

4. **Push to tap repository:**
   ```bash
   git add .
   git commit -m "Add Iris formula v5.1"
   git remote add origin git@github.com:mwangiiharun/homebrew-iris.git
   git push -u origin main
   ```

## Test Installation

1. **Test local formula:**
   ```bash
   brew install --build-from-source Formula/iris.rb
   iris --version  # Should show v5.1
   ```

2. **Test from tap:**
   ```bash
   brew tap mwangiiharun/homebrew-iris
   brew install iris
   iris --version
   ```

## Verify Everything Works

- [ ] `iris --version` shows correct version
- [ ] `iris --help` works
- [ ] `iris` runs a speed test successfully
- [ ] `iris --json` outputs valid JSON
- [ ] `iris --history` works (if previous tests exist)
- [ ] `iris --stats` works

## Announcement

Once verified, users can install with:
```bash
brew tap mwangiiharun/homebrew-iris
brew install iris
```

Or if using your tap name:
```bash
brew tap mwangiiharun/homebrew-iris
brew install iris
```

