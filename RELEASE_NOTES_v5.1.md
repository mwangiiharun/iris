# Release Notes - Iris v5.1

## 🚀 What's New

Iris v5.1 introduces major improvements including command-line options, performance optimizations, and Homebrew support!

### ⚡ New Features

#### Command-Line Interface
- **`--help` / `-h`** - Comprehensive help documentation
- **`--version` / `-v`** - Show version information
- **`--quiet` / `-q`** - Quiet mode with minimal output (perfect for scripting)
- **`--json` / `-j`** - Machine-readable JSON output for automation
- **`--history` / `-H`** - View test history (last 20 tests)
- **`--stats` / `-s`** - Detailed statistics (min, max, average, standard deviation)
- **`--no-banner`** - Skip banner display

#### JSON Output Format
Iris now supports structured JSON output for easy integration with scripts and monitoring tools:

```json
{
  "timestamp": "2025-11-02T12:00:00Z",
  "download_mbps": 95.42,
  "upload_mbps": 45.23,
  "ping_ms": 12.34,
  "server": "Server Name",
  "isp": "ISP Name",
  "location": {
    "city": "City",
    "country": "Country",
    "ip": "1.2.3.4"
  },
  "rating": "🌟 Excellent"
}
```

#### Enhanced Statistics
The new `--stats` command provides comprehensive analysis of your test history:
- Total test count
- Download/Upload/Ping statistics:
  - Average
  - Minimum
  - Maximum
  - Standard deviation

### 🔧 Performance Improvements

- **Optimized Color Calculations** - Replaced multiple `bc` calls with native zsh arithmetic for faster execution
- **Code Refactoring** - Extracted bandwidth calculation into reusable function
- **Memory Optimization** - Fixed sparkline growth issue (now limited to 60 characters)

### 📦 Homebrew Support

Iris is now installable via Homebrew! 

**Installation:**
```bash
# From local formula
brew install --build-from-source Formula/iris.rb

# Or set up your own tap (see HOMEBREW_SETUP.md)
brew tap yourusername/homebrew-iris
brew install iris
```

### 🐛 Bug Fixes

- Fixed sparkline memory leak (was growing unbounded)
- Improved error handling for missing dependencies
- Better fallback behavior when tools are unavailable

### 📚 Documentation

- Complete README with installation and usage instructions
- Comprehensive Homebrew setup guide
- Release checklist for maintainers
- Installation documentation

## 🔄 Migration Guide

### For Users

No breaking changes! Existing usage continues to work as before:

```bash
# Still works as always
iris

# Now with new options!
iris --json        # JSON output
iris --quiet       # Minimal output
iris --history     # View past tests
iris --stats       # Detailed statistics
```

### For Scripts

If you're using Iris in scripts, you can now use:
- `--json` for structured output
- `--quiet` for minimal terminal output

## 📋 Full Changelog

### Added
- Command-line argument parsing
- JSON output format (`--json`)
- Test history viewer (`--history`)
- Detailed statistics (`--stats`)
- Quiet mode (`--quiet`)
- Help system (`--help`)
- Homebrew formula and installation support
- Helper scripts for SHA256 calculation and tap setup
- GitHub Actions workflow for automated releases
- Comprehensive documentation

### Changed
- Optimized `ping_color_code()` function (faster execution)
- Extracted bandwidth calculation to reusable function
- Limited sparkline length to prevent memory issues
- Improved error messages and fallbacks

### Fixed
- Sparkline memory growth issue
- Potential division by zero in calculations
- Better handling of missing optional tools

## 🙏 Credits

Created by ** Mwangi Kinuthia** (Mwangii K)

## 📦 Installation

### Homebrew (Recommended)
```bash
brew tap mwangiiharun/homebrew-iris
brew install iris
```

### Manual Installation
```bash
git clone https://github.com/mwangiiharun/iris.git
cd iris
chmod +x bin/iris
export PATH="$PATH:$(pwd)/bin"
```

### Dependencies
```bash
brew install jq bc figlet lolcat ookla/speedtest/speedtest
```

## 🔗 Links

- **Repository:** https://github.com/mwangiiharun/iris
- **Issues:** https://github.com/mwangiiharun/iris/issues
- **Documentation:** See README.md and HOMEBREW_SETUP.md

---

**Full Changelog:** See git history for detailed commit list

