class Iris < Formula
  desc "⚡ Iris — Fancy terminal speed test with gradients and sparkline"
  homepage "https://github.com/mwangiiharun/iris"
  url "https://github.com/mwangiiharun/iris/archive/refs/tags/v5.2.tar.gz"
  sha256 "243b70ea9817c103683566e0193ea838bbbe0ffe79cb3bd078288d975caabe48"
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
    assert_match "Iris v5.2", shell_output("#{bin}/iris --version")
    assert_match "Iris", shell_output("#{bin}/iris --help")
  end
end
