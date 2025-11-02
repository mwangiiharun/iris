class Iris < Formula
  desc "⚡ Iris — Fancy terminal speed test with gradients and sparkline"
  homepage "https://github.com/mwangiiharun/iris"
  url "https://github.com/mwangiiharun/iris/archive/refs/tags/v5.2.tar.gz"
  sha256 "d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed"
  license "MIT"
  version "5.2"

  depends_on "jq"
  depends_on "bc"
  depends_on "figlet"
  depends_on "lolcat"
  depends_on "ookla/speedtest/speedtest"

  def install
    bin.install "bin/iris"
    # Ensure the script is executable
    chmod 0755, bin/"iris"
  end

  test do
    assert_match "Hermes v5.1", shell_output("#{bin}/iris --version")
    assert_match "Hermes", shell_output("#{bin}/iris --help")
  end
end
