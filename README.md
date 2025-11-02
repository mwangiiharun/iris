# ⚡ Iris — The Messenger of Speed

A beautiful, feature-rich terminal speed test tool with real-time visualization, gradients, and sparklines.

```
     ____     _
   /  _/____(_)____
   / // ___/ / ___/
 _/ // /  / (__  )
/___/_/  /_/____/

```

## Features

- ⚡ Real-time speed test visualization with live progress bars
- 📊 Beautiful gradient latency graphs
- 📈 Sparkline visualization during ping tests
- 🌍 Automatic geolocation and ISP detection
- 📝 Test history tracking with statistics
- 🎨 Color-coded results and ratings
- 📋 JSON output for scripting and automation
- 🔧 Multiple command-line options for flexibility

## Installation

### Homebrew (Recommended)

**All dependencies are automatically installed** during Homebrew installation, including:
- `jq`, `bc`, `figlet`, `lolcat` (via Homebrew)
- `speedtest` (Ookla Speedtest CLI - automatically downloaded if needed)

#### Option 1: Install from Tap (Recommended)

```bash
brew tap mwangiiharun/homebrew-iris
brew install iris
```

#### Option 2: Install from Local Formula

For testing local changes:

```bash
# Create local tap for testing
brew tap-new mwangiiharun/iris-test
cp Formula/iris.rb $(brew --repository)/Library/Taps/mwangiiharun/homebrew-iris-test/Formula/iris.rb
brew install --build-from-source mwangiiharun/iris-test/iris
```

### Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/mwangiiharun/iris.git
cd iris
```

2. Make executable:
```bash
chmod +x bin/iris
```

3. Add to PATH (add to `~/.zshrc`):
```bash
export PATH="$PATH:$(pwd)/bin"
```

4. Install dependencies:
```bash
# Install required dependencies manually
brew install jq bc figlet lolcat

# Ookla Speedtest CLI (required for speed tests)
# The script will automatically try to install this if missing, or you can install manually:
# Option 1: Try via tap
brew tap ookla/speedtest && brew install speedtest

# Option 2: Download from https://www.speedtest.net/apps/cli
```

**Note:** When installed via Homebrew, all dependencies are automatically installed for you.

## Usage

### Basic Usage

Run a speed test:
```bash
iris
```

### Command-Line Options

```bash
iris [OPTIONS]
```

**Options:**
- `-h, --help` - Show help message
- `-v, --version` - Show version information
- `-q, --quiet` - Quiet mode (minimal output)
- `-j, --json` - Output results as JSON
- `-H, --history` - Show test history (last 20 tests)
- `-s, --stats` - Show detailed statistics (min/max/avg/std dev)
- `--no-banner` - Skip banner display

### Examples

```bash
# Normal speed test
iris

# JSON output (for scripting)
iris --json

# Quiet mode (minimal output)
iris --quiet

# View test history
iris --history

# Detailed statistics
iris --stats

# Skip banner
iris --no-banner
```

## Output Formats

### Standard Output
Beautiful terminal output with colors, graphs, and visualizations.

### JSON Output
Machine-readable JSON format for automation:
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

## Test History

Iris automatically saves test results to `~/.iris_history` in CSV format:

```
timestamp,download,upload,ping,server,isp
2025-11-02 12:00:00,95.42,45.23,12.34,Server Name,ISP Name
```

View history:
```bash
iris --history
```

Get statistics:
```bash
iris --stats
```

## Requirements

- macOS or Linux
- zsh shell
- Homebrew (for installation and dependencies)

**Dependencies (automatically installed via Homebrew):**
- `speedtest` (Ookla Speedtest CLI) - Automatically downloaded if not available
- `jq` - JSON processor
- `bc` - Calculator
- `figlet` - ASCII art
- `lolcat` - Rainbow colors

All dependencies are automatically installed when using Homebrew. Manual installation requires installing these separately.

## Performance Ratings

Ping quality ratings:
- 🌟 **Excellent**: < 30ms
- 👍 **Good**: 30-70ms
- 🐢 **Poor**: > 70ms

## Troubleshooting

### Missing Dependencies

**If installed via Homebrew:** Dependencies should be automatically installed. If you encounter issues:

1. Reinstall Iris: `brew reinstall iris`
2. The formula will attempt to install speedtest automatically if missing

**If installed manually:** Install dependencies:

```bash
brew install jq bc figlet lolcat

# For speedtest, the script will prompt you with installation instructions
# Or install manually: brew tap ookla/speedtest && brew install speedtest
```

### Permission Denied

Make sure the script is executable:
```bash
chmod +x bin/iris
```

### Speedtest Issues

**If installed via Homebrew:** Speedtest should be automatically installed. To verify:
```bash
speedtest --version
```

If speedtest is missing, the formula will attempt to download it automatically. If that fails:
```bash
# Try manual installation
brew tap ookla/speedtest && brew install speedtest

# Or download from: https://www.speedtest.net/apps/cli
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Created by **Harun Mwangi Kinuthia** (Mwangii K)

## Acknowledgments

- Uses Ookla Speedtest CLI for actual speed testing
- Built with ❤️ for the terminal
