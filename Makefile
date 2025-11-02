.PHONY: install test clean help

help:
	@echo "Iris - The Messenger of Speed"
	@echo ""
	@echo "Available targets:"
	@echo "  install    - Install via Homebrew from local formula"
	@echo "  test       - Run tests"
	@echo "  clean      - Clean temporary files"
	@echo "  sha256     - Calculate SHA256 for release tarball"
	@echo "  deploy     - Bump version and deploy (interactive)"
	@echo ""

install:
	@echo "Installing Iris via Homebrew..."
	@echo "Creating local tap for testing..."
	@brew tap-new mwangiiharun/iris-test 2>/dev/null || true
	@cp Formula/iris.rb $$(brew --repository)/Library/Taps/mwangiiharun/homebrew-iris-test/Formula/iris.rb 2>/dev/null || echo "Tap may already exist"
	@brew tap mwangiiharun/iris-test 2>/dev/null || true
	@brew install --build-from-source mwangiiharun/iris-test/iris

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
	@echo "curl -L https://github.com/mwangiiharun/iris/archive/refs/tags/v5.1.tar.gz | shasum -a 256"
	@echo ""
	@echo "Then update Formula/iris.rb with the SHA256 value"

deploy:
	@./scripts/bump-and-deploy.sh

