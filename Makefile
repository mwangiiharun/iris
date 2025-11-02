.PHONY: install test clean help

help:
	@echo "Iris - The Messenger of Speed"
	@echo ""
	@echo "Available targets:"
	@echo "  install    - Install via Homebrew from local formula"
	@echo "  test       - Run tests"
	@echo "  clean      - Clean temporary files"
	@echo "  sha256     - Calculate SHA256 for release tarball"
	@echo ""

install:
	@echo "Installing Iris via Homebrew..."
	brew install --build-from-source Formula/iris.rb

uninstall:
	@echo "Uninstalling Iris..."
	brew uninstall iris || true

test:
	@echo "Testing Iris..."
	@chmod +x bin/iris
	@bin/iris --version
	@bin/iris --help

clean:
	@echo "Cleaning temporary files..."
	@rm -f /tmp/iris_*.json
	@echo "Done"

sha256:
	@echo "Calculate SHA256 for your release tarball:"
	@echo "curl -L https://github.com/mwangiiharun/hermes/archive/refs/tags/v5.1.tar.gz | shasum -a 256"
	@echo ""
	@echo "Then update Formula/iris.rb with the SHA256 value"

