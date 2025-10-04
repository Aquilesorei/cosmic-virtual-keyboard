#!/bin/bash

# Script to generate cargo-sources.json for Flatpak build
# This is needed for offline Flatpak builds

set -e

echo "Generating cargo-sources.json for Flatpak..."

# Check if flatpak-cargo-generator.py is available
if ! command -v flatpak-cargo-generator.py &> /dev/null; then
    echo "Installing flatpak-cargo-generator..."
    
    # Try to install from package manager first
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y flatpak-builder-tools
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y flatpak-builder-tools
    else
        # Fallback: download manually
        echo "Downloading flatpak-cargo-generator manually..."
        wget -O flatpak-cargo-generator.py https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/master/cargo/flatpak-cargo-generator.py
        chmod +x flatpak-cargo-generator.py
        CARGO_GENERATOR="./flatpak-cargo-generator.py"
    fi
else
    CARGO_GENERATOR="flatpak-cargo-generator.py"
fi

# Generate the cargo sources
if [ -z "$CARGO_GENERATOR" ]; then
    CARGO_GENERATOR="flatpak-cargo-generator.py"
fi

echo "Running cargo generator..."
python3 "$CARGO_GENERATOR" Cargo.lock -o cargo-sources.json

echo "✅ cargo-sources.json generated successfully"
echo "You can now build the Flatpak with:"
echo "  flatpak-builder --user --install build-dir com.cosmic.VirtualKeyboard.yml"