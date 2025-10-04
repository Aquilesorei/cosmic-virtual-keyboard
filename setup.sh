#!/bin/bash

# COSMIC Virtual Keyboard Applet Setup Script
# This script automates the installation of wvkbd and the COSMIC applet

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if we're on a supported system
check_system() {
    print_step "Checking system compatibility..."
    
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        print_error "This script is designed for Linux systems only."
        exit 1
    fi
    
    if ! command_exists "apt"; then
        print_error "This script requires apt package manager (Ubuntu/Debian-based systems)."
        exit 1
    fi
    
    print_success "System compatibility check passed"
}

# Function to install system dependencies
install_system_deps() {
    print_step "Installing system dependencies..."
    
    sudo apt update
    
    # Dependencies for wvkbd
    sudo apt install -y \
        build-essential \
        pkg-config \
        libwayland-dev \
        libxkbcommon-dev \
        git
    
    # Dependencies for Rust (if not already installed)
    if ! command_exists "rustc"; then
        print_step "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
    else
        print_success "Rust is already installed"
    fi
    
    print_success "System dependencies installed"
}

# Function to install wvkbd
install_wvkbd() {
    print_step "Installing wvkbd virtual keyboard..."
    
    # Create temp directory for build
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Clone wvkbd repository
    git clone https://github.com/jjsullivan5196/wvkbd.git
    cd wvkbd
    
    # Build wvkbd
    print_step "Building wvkbd..."
    make
    
    # Install to user's local bin
    mkdir -p ~/.local/bin
    cp wvkbd-mobintl ~/.local/bin/
    
    # Make sure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        print_warning "Added ~/.local/bin to PATH in ~/.bashrc. Please restart your shell or run: source ~/.bashrc"
    fi
    
    # Clean up
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    print_success "wvkbd installed to ~/.local/bin/wvkbd-mobintl"
}

# Function to build and install the COSMIC applet
install_applet() {
    print_step "Building COSMIC Virtual Keyboard Applet..."
    
    # Ensure we're in the project directory
    if [[ ! -f "Cargo.toml" ]]; then
        print_error "Could not find Cargo.toml. Please run this script from the project root directory."
        exit 1
    fi
    
    # Build the applet
    cargo build --release
    
    print_step "Installing COSMIC applet..."
    
    # Install binary
    sudo cp target/release/cosmic-virtual-keyboard /usr/bin/
    
    # Install desktop entry
    sudo cp cosmic-virtual-keyboard.desktop /usr/share/applications/
    
    print_success "COSMIC applet installed"
}

# Function to verify installation
verify_installation() {
    print_step "Verifying installation..."
    
    # Check wvkbd
    if command_exists "wvkbd-mobintl"; then
        print_success "wvkbd-mobintl found in PATH"
    else
        print_warning "wvkbd-mobintl not found in current PATH. You may need to restart your shell."
    fi
    
    # Check applet binary
    if [[ -f "/usr/bin/cosmic-virtual-keyboard" ]]; then
        print_success "COSMIC applet binary installed"
    else
        print_error "COSMIC applet binary not found"
        return 1
    fi
    
    # Check desktop entry
    if [[ -f "/usr/share/applications/cosmic-virtual-keyboard.desktop" ]]; then
        print_success "Desktop entry installed"
    else
        print_error "Desktop entry not found"
        return 1
    fi
    
    print_success "Installation verification completed"
}

# Function to provide next steps
show_next_steps() {
    echo
    echo -e "${GREEN}🎉 Installation Complete!${NC}"
    echo
    echo "Next steps:"
    echo "1. ${BLUE}Restart your shell${NC} or run: ${YELLOW}source ~/.bashrc${NC}"
    echo "2. ${BLUE}Log out and log back in${NC} to COSMIC DE (or restart COSMIC)"
    echo "3. ${BLUE}Open COSMIC Settings${NC} → Desktop → Panel"
    echo "4. ${BLUE}Click 'Add Applet'${NC} and select 'Virtual Keyboard'"
    echo "5. ${BLUE}Click the keyboard icon${NC} in your panel to control the virtual keyboard!"
    echo
    echo "🔧 ${BLUE}Troubleshooting:${NC}"
    echo "   - If the applet doesn't appear, try: ${YELLOW}sudo systemctl restart cosmic-applet-virtual-keyboard${NC}"
    echo "   - Test wvkbd manually: ${YELLOW}wvkbd-mobintl -L 200${NC}"
    echo "   - Check logs with: ${YELLOW}journalctl -f -u cosmic-panel${NC}"
    echo
    echo "📚 For more information, see the README.md file."
}

# Function to handle cleanup on error
cleanup_on_error() {
    print_error "Installation failed. Cleaning up..."
    # Remove any partially installed files
    sudo rm -f /usr/bin/cosmic-virtual-keyboard 2>/dev/null || true
    sudo rm -f /usr/share/applications/cosmic-virtual-keyboard.desktop 2>/dev/null || true
}

# Main installation flow
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║             COSMIC Virtual Keyboard Applet Setup            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    
    # Set up error handling
    trap cleanup_on_error ERR
    
    # Run installation steps
    check_system
    install_system_deps
    install_wvkbd
    install_applet
    verify_installation
    
    # Show completion message
    show_next_steps
}

# Check if running as root (not recommended)
if [[ $EUID -eq 0 ]]; then
    print_warning "Running as root is not recommended. The script will use sudo when needed."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Run main installation
main "$@"