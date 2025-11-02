class Hermes < Formula
  desc "⚡ Hermes — Fancy terminal speed test with gradients and sparkline"
  homepage "https://github.com/mwangiiharun/hermes"
  url "https://github.com/mwangiiharun/hermes/archive/refs/tags/v5.1.tar.gz"
  sha256 "REPLACE_WITH_REAL_SHA256"
  license "MIT"
  version "5.1"

  depends_on "jq"
  depends_on "bc"
  depends_on "figlet"
  depends_on "lolcat"
  depends_on "ookla/speedtest/speedtest"

  def install
    bin.install "bin/hermes"
    # Ensure the script is executable
    chmod 0755, bin/"hermes"
  end

  test do
    assert_match "Hermes v5.1", shell_output("#{bin}/hermes --version")
    assert_match "Hermes", shell_output("#{bin}/hermes --help")
  end
end
