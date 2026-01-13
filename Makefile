.PHONY: install uninstall test clean help

PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin

help:
	@echo "kubectl-beam Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  install    Install kubectl-beam to $(BINDIR)"
	@echo "  uninstall  Remove kubectl-beam from $(BINDIR)"
	@echo "  test       Run test suite (requires bats)"
	@echo "  clean      Remove temporary files"
	@echo "  help       Show this help message"

install:
	@echo "Installing kubectl-beam to $(BINDIR)"
	@mkdir -p $(BINDIR)
	@cp kubectl-beam $(BINDIR)/kubectl-beam
	@chmod +x $(BINDIR)/kubectl-beam
	@echo "Installation complete. Ensure $(BINDIR) is in your PATH."
	@echo "Verify with: kubectl beam --version"

uninstall:
	@echo "Removing kubectl-beam from $(BINDIR)"
	@rm -f $(BINDIR)/kubectl-beam
	@echo "Uninstallation complete"

test:
	@if command -v bats >/dev/null 2>&1; then \
		bats test/kubectl-beam.bats; \
	else \
		echo "Error: bats is not installed"; \
		echo "Install with: brew install bats-core (macOS) or apt-get install bats (Linux)"; \
		exit 1; \
	fi

test-integration:
	@if command -v bats >/dev/null 2>&1; then \
		bats test/kubectl-beam-integration.bats; \
	else \
		echo "Error: bats is not installed"; \
		echo "Install with: brew install bats-core (macOS) or apt-get install bats (Linux)"; \
		exit 1; \
	fi

test-all: test test-integration

clean:
	@echo "Cleaning temporary files"
	@find . -name "*.scap.gz" -delete
	@echo "Clean complete"
