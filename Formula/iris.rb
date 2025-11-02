class Iris < Formula
  desc "⚡ Iris — Fancy terminal speed test with gradients and sparkline"
  homepage "https://github.com/mwangiiharun/iris"
  url "https://github.com/mwangiiharun/iris/archive/refs/tags/v5.3.tar.gz"
  sha256 "b71ce80db820b003c7dbdfad71ed4860d329e91e449b5b7344417509bc357495"
  license "MIT"
  version "5.3"

  depends_on "jq"
  depends_on "bc"
  depends_on "figlet"
  depends_on "lolcat"

  def install
    bin.install "bin/iris"
    # Ensure the script is executable
    chmod 0755, bin/"iris"
  end

  def post_install
    # Install Ookla Speedtest CLI if not present
    speedtest_binary = "#{bin}/speedtest"
    return if File.exist?(speedtest_binary)
    
    # Check if speedtest is already in PATH
    speedtest_in_path = `which speedtest 2>/dev/null`.strip
    return if speedtest_in_path != "" && File.exist?(speedtest_in_path)
    
    ohai "Installing Ookla Speedtest CLI..."
    
    begin
      # Try installing via tap first
      tap_result = system("brew", "tap", "ookla/speedtest", exception: false)
      if tap_result
        install_result = system("brew", "install", "speedtest", exception: false)
        if install_result
          ohai "Speedtest CLI installed via Homebrew tap"
          return
        end
      end
    rescue => e
      # Continue to direct download if tap fails
      odie "Tap installation failed: #{e.message}" if ENV["HOMEBREW_DEVELOPER"]
    end
    
    # If tap fails, download binary directly from Ookla
    ohai "Downloading speedtest binary directly..."
    
    arch = Hardware::CPU.arm? ? "arm64" : "x86_64"
    # Use Ookla's official download endpoint
    url = "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-macosx-#{arch}.tgz"
    
    # Download to temp location
    download_path = "#{Dir.tmpdir}/speedtest-#{arch}.tgz"
    
    curl_result = system("curl", "-L", "-f", url, "-o", download_path, exception: false)
    unless curl_result
      opoo "Could not download speedtest binary"
      opoo "Please install manually: brew tap ookla/speedtest && brew install speedtest"
      opoo "Or download from: https://www.speedtest.net/apps/cli"
      return
    end
    
    tar_result = system("tar", "-xzf", download_path, "-C", bin, "speedtest", exception: false)
    if tar_result && File.exist?(speedtest_binary)
      File.chmod(0755, speedtest_binary)
      ohai "Speedtest CLI installed successfully"
    else
      opoo "Could not extract speedtest binary"
      opoo "Please install manually: brew tap ookla/speedtest && brew install speedtest"
    end
  rescue => e
    opoo "Could not install speedtest automatically: #{e.message}"
    opoo "Please install manually: brew tap ookla/speedtest && brew install speedtest"
    opoo "Or download from: https://www.speedtest.net/apps/cli"
  end

  test do
    assert_match "Iris v5.2", shell_output("#{bin}/iris --version")
    assert_match "Iris", shell_output("#{bin}/iris --help")
  end
end
