# 🚀 Iris v5.1 - The Messenger of Speed

## Major Release with CLI Options, Performance Improvements, and Homebrew Support!

### ✨ What's New

#### 🎯 Command-Line Interface
Iris now supports a full CLI with powerful options:

- `--help` / `-h` - Show help message
- `--version` / `-v` - Show version
- `--quiet` / `-q` - Quiet mode (minimal output)
- `--json` / `-j` - JSON output for scripting
- `--history` / `-H` - View test history
- `--stats` / `-s` - Detailed statistics (min/max/avg/std dev)
- `--no-banner` - Skip banner

#### 📊 Enhanced Statistics
New `--stats` command provides comprehensive analysis:
- Total test count
- Min/Max/Average/Std Dev for Download, Upload, and Ping

#### 📋 JSON Output
Machine-readable output perfect for automation and monitoring:
```json
{
  "timestamp": "2025-11-02T12:00:00Z",
  "download_mbps": 95.42,
  "upload_mbps": 45.23,
  "ping_ms": 12.34,
  "server": "Server Name",
  "isp": "ISP Name",
  "location": { "city": "...", "country": "...", "ip": "..." },
  "rating": "🌟 Excellent"
}
```

#### 📦 Homebrew Support
Install Iris via Homebrew!

```bash
brew tap mwangiiharun/homebrew-iris
brew install iris
```

### ⚡ Performance Improvements

- **Faster color calculations** - Optimized `ping_color_code()` using zsh arithmetic
- **Code refactoring** - Extracted reusable bandwidth calculation function
- **Memory optimization** - Fixed sparkline memory leak (limited to 60 chars)

### 🐛 Bug Fixes

- Fixed unbounded sparkline growth (memory leak)
- Improved error handling for missing dependencies
- Better fallback behavior

### 📚 Documentation

- Complete README with installation guide
- Homebrew setup documentation
- Release checklist
- Helper scripts for maintenance

### 🔄 Breaking Changes

**None!** All existing usage continues to work. New features are additive.

### 📥 Installation

**Homebrew:**
```bash
brew tap mwangiiharun/homebrew-iris
brew install iris
```

**Manual:**
```bash
git clone https://github.com/mwangiiharun/iris.git
cd iris && chmod +x bin/iris
export PATH="$PATH:$(pwd)/bin"
```

### 🎯 Quick Start

```bash
# Run speed test
iris

# JSON output for scripts
iris --json

# View history
iris --history

# Get statistics
iris --stats

# Quiet mode
iris --quiet
```

### 📋 Requirements

- macOS or Linux
- zsh shell
- Homebrew dependencies: `jq`, `bc`, `figlet`, `lolcat`, `speedtest`

---

**Full Changelog:** See [RELEASE_NOTES_v5.1.md](RELEASE_NOTES_v5.1.md)

**Documentation:** See [README.md](README.md)

