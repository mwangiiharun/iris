# Installation Guide

## Homebrew Installation

### Option 1: Install from Tap (Recommended)

If you have a Homebrew tap repository set up:

```bash
brew install mwangiiharun/tap/iris
```

### Option 2: Install from Local Formula

1. Clone or download this repository
2. Install using the local formula:

```bash
brew install --build-from-source Formula/iris.rb
```

### Option 3: Create Your Own Tap

1. Create a GitHub repository named `homebrew-tap` (or any name you prefer)
2. Create a `Formula` directory in the repository
3. Copy `Formula/iris.rb` to your tap repository
4. Calculate the SHA256 hash for the release tarball:

```bash
# For a tagged release tarball
curl -L https://github.com/mwangiiharun/hermes/archive/refs/tags/v5.1.tar.gz | shasum -a 256
```

5. Update the `sha256` value in the formula
6. Commit and push to your tap repository
7. Install from your tap:

```bash
brew tap yourusername/homebrew-tap
brew install iris
```

## Manual Installation

1. Make the script executable:
```bash
chmod +x bin/iris
```

2. Add to your PATH (add to `~/.zshrc` or `~/.bashrc`):
```bash
export PATH="$PATH:/path/to/iris/bin"
```

3. Install dependencies:
```bash
brew install jq bc figlet lolcat ookla/speedtest/speedtest
```

## Verifying Installation

After installation, verify it works:

```bash
iris --version
iris --help
```

## Updating

To update Iris:

```bash
brew upgrade iris
```

Or if installed manually:

```bash
cd /path/to/iris
git pull  # or download latest release
```

