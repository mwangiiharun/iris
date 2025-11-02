.PHONY: install test clean help

help:
	@echo "Hermes - The Messenger of Speed"
	@echo ""
	@echo "Available targets:"
	@echo "  install    - Install via Homebrew from local formula"
	@echo "  test       - Run tests"
	@echo "  clean      - Clean temporary files"
	@echo "  sha256     - Calculate SHA256 for release tarball"
	@echo ""

install:
	@echo "Installing Hermes via Homebrew..."
	brew install --build-from-source Formula/hermes.rb

uninstall:
	@echo "Uninstalling Hermes..."
	brew uninstall hermes || true

test:
	@echo "Testing Hermes..."
	@chmod +x bin/hermes
	@bin/hermes --version
	@bin/hermes --help

clean:
	@echo "Cleaning temporary files..."
	@rm -f /tmp/hermes_*.json
	@echo "Done"

sha256:
	@echo "Calculate SHA256 for your release tarball:"
	@echo "curl -L https://github.com/mwangiiharun/hermes/archive/refs/tags/v5.1.tar.gz | shasum -a 256"
	@echo ""
	@echo "Then update Formula/hermes.rb with the SHA256 value"

