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

#### Option 1: Install from Local Formula

```bash
brew install --build-from-source Formula/iris.rb
```

#### Option 2: Create Your Own Tap

1. Create a GitHub repository (e.g., `homebrew-tap`)
2. Copy `Formula/iris.rb` to `Formula/iris.rb` in your tap
3. Calculate SHA256 for your release tarball
4. Update the formula with the SHA256
5. Install:

```bash
brew tap yourusername/homebrew-tap
brew install iris
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
brew install jq bc figlet lolcat ookla/speedtest/speedtest
```

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
- Homebrew (for dependencies)

**Dependencies:**
- `speedtest` (Ookla Speedtest CLI)
- `jq` - JSON processor
- `bc` - Calculator
- `figlet` - ASCII art
- `lolcat` - Rainbow colors

## Performance Ratings

Ping quality ratings:
- 🌟 **Excellent**: < 30ms
- 👍 **Good**: 30-70ms
- 🐢 **Poor**: > 70ms

## Troubleshooting

### Missing Dependencies

If you get "command not found" errors, install missing dependencies:

```bash
brew install jq bc figlet lolcat ookla/speedtest/speedtest
```

### Permission Denied

Make sure the script is executable:
```bash
chmod +x bin/iris
```

### Speedtest Issues

Make sure Ookla Speedtest CLI is properly installed:
```bash
brew install ookla/speedtest/speedtest
speedtest --version
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
