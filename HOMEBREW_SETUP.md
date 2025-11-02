# Homebrew Installation Setup Guide

This guide will help you set up Iris for Homebrew installation.

## Quick Start

### Option 1: Install from Local Formula (Testing)

```bash
# Calculate SHA256 first (if you have a GitHub release)
./scripts/calculate-sha256.sh v5.1

# Update Formula/iris.rb with the SHA256
# Then install:
make install
# or
brew install --build-from-source Formula/iris.rb
```

### Option 2: Set Up Your Own Tap (Production)

#### Step 1: Create GitHub Repository

Create a new GitHub repository for your tap (e.g., `homebrew-iris` or `homebrew-tap`).

#### Step 2: Set Up Tap Structure

```bash
./scripts/setup-tap.sh homebrew-iris mwangiiharun
```

This will create the tap structure in a sibling directory.

#### Step 3: Calculate SHA256

Before releasing, calculate the SHA256 hash for your release tarball:

```bash
./scripts/calculate-sha256.sh v5.1
```

Or manually:
```bash
curl -L https://github.com/mwangiiharun/hermes/archive/refs/tags/v5.1.tar.gz | shasum -a 256
```

#### Step 4: Update Formula

Edit `Formula/iris.rb` in your tap repository and replace `REPLACE_WITH_REAL_SHA256` with the calculated SHA256.

#### Step 5: Push to GitHub

```bash
cd ../homebrew-iris  # or your tap directory
git add .
git commit -m "Add Iris formula"
git remote add origin git@github.com:mwangiiharun/homebrew-iris.git
git push -u origin main
```

#### Step 6: Install from Tap

```bash
brew tap mwangiiharun/homebrew-iris
brew install iris
```

## Making a Release

When creating a new release:

1. **Tag the release** in your main repository:
   ```bash
   git tag v5.1
   git push origin v5.1
   ```

2. **Create GitHub release** with a tarball, or let GitHub auto-generate it.

3. **Calculate SHA256**:
   ```bash
   ./scripts/calculate-sha256.sh v5.1
   ```

4. **Update formula** in your tap repository with:
   - New version number
   - New SHA256
   - Updated URL (if needed)

5. **Commit and push** the updated formula:
   ```bash
   cd ../homebrew-iris
   git add Formula/iris.rb
   git commit -m "Update iris to v5.1"
   git push
   ```

## Formula File Structure

Your `Formula/iris.rb` should look like:

```ruby
class Iris < Formula
  desc "⚡ Iris — Fancy terminal speed test with gradients and sparkline"
  homepage "https://github.com/mwangiiharun/hermes"
  url "https://github.com/mwangiiharun/hermes/archive/refs/tags/v5.1.tar.gz"
  sha256 "abc123def456..."  # Real SHA256 hash
  license "MIT"
  version "5.1"

  depends_on "jq"
  depends_on "bc"
  depends_on "figlet"
  depends_on "lolcat"
  depends_on "ookla/speedtest/speedtest"

  def install
    bin.install "bin/iris"
    chmod 0755, bin/"iris"
  end

  test do
    assert_match "Iris v5.1", shell_output("#{bin}/iris --version")
    assert_match "Iris", shell_output("#{bin}/iris --help")
  end
end
```

## Testing the Formula

Before pushing to your tap, test locally:

```bash
# Test installation
brew install --build-from-source Formula/iris.rb

# Test the installed binary
iris --version
iris --help

# Run formula tests
brew test iris

# Uninstall if needed
brew uninstall iris
```

## Troubleshooting

### Formula install fails with "SHA256 mismatch"

This means the calculated SHA256 doesn't match the actual tarball. Recalculate:

```bash
./scripts/calculate-sha256.sh v5.1
```

### "No such file or directory" errors

Make sure:
- The release tarball URL is correct
- The GitHub release exists
- The version tag exists

### "Dependency not found" errors

Make sure all dependencies are available in Homebrew:

```bash
brew install jq bc figlet lolcat
brew tap ookla/speedtest
brew install ookla/speedtest/speedtest
```

## Automation (Optional)

For automatic updates when you create a GitHub release, you can use the GitHub Actions workflow provided (`.github/workflows/homebrew.yml`). This requires:

1. Setting up a tap repository
2. Configuring GitHub Actions secrets
3. The workflow will automatically update the formula when you create a release

## Additional Resources

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Tap Documentation](https://docs.brew.sh/Taps)
- [Creating a Homebrew Tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)

