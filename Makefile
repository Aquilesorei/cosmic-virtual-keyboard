.PHONY: build install clean flatpak-build flatpak-install flatpak-run generate-sources

# Build the applet
build:
	cargo build --release

# Install locally (requires sudo)
install: build
	sudo cp target/release/cosmic-virtual-keyboard /usr/bin/
	sudo cp cosmic-virtual-keyboard.desktop /usr/share/applications/

# Clean build artifacts
clean:
	cargo clean
	rm -rf build-dir
	rm -f cargo-sources.json

# Generate cargo sources for Flatpak
generate-sources:
	./generate-cargo-sources.sh

# Build Flatpak package
flatpak-build: generate-sources
	flatpak-builder --user --force-clean build-dir com.cosmic.VirtualKeyboard.yml

# Build and install Flatpak package  
flatpak-install: generate-sources
	flatpak-builder --user --install --force-clean build-dir com.cosmic.VirtualKeyboard.yml

# Run the Flatpak version
flatpak-run:
	flatpak run com.cosmic.VirtualKeyboard

# Development build and test
dev: build
	./target/release/cosmic-virtual-keyboard

# Complete setup (manual installation)
setup:
	./setup.sh

# Help target
help:
	@echo "Available targets:"
	@echo "  build           - Build the applet with cargo"
	@echo "  install         - Build and install system-wide (needs sudo)"
	@echo "  clean           - Clean build artifacts"
	@echo "  generate-sources- Generate cargo sources for Flatpak"
	@echo "  flatpak-build   - Build Flatpak package"
	@echo "  flatpak-install - Build and install Flatpak package"
	@echo "  flatpak-run     - Run the Flatpak version"
	@echo "  dev             - Build and run for testing"
	@echo "  setup           - Run the complete setup script"
	@echo "  help            - Show this help message"