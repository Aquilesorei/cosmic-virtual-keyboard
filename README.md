# COSMIC Virtual Keyboard Applet

A clean, native COSMIC DE panel applet for controlling virtual keyboards on Wayland systems. This project provides an elegant solution for Pop!_OS users who need reliable virtual keyboard functionality without the complexity of building a full keyboard from scratch.

## 🚀 New Approach

Instead of implementing a complete virtual keyboard, this project takes a **smart integration approach**:

1. **🎹 Uses wvkbd** - A mature, well-tested virtual keyboard ([jjsullivan5196/wvkbd](https://github.com/jjsullivan5196/wvkbd))
2. **🎛️ Adds COSMIC Panel Integration** - A native applet that fits perfectly into COSMIC DE's design language
3. **🔧 Provides Easy Control** - Simple toggle, show, hide, and status functionality

## 📋 Features

### Panel Integration
- **Native COSMIC Applet**: Appears as a keyboard icon in your COSMIC panel
- **Status Aware**: Shows whether the virtual keyboard is currently running
- **Click to Control**: Single click opens the control popup

### Virtual Keyboard Control
- **Start/Stop**: Toggle the virtual keyboard on/off
- **Show/Hide**: Control visibility without stopping the process  
- **Signal Management**: Uses proper POSIX signals (SIGUSR1/SIGUSR2)
- **Process Tracking**: Monitors keyboard status via process detection

### User Experience
- **No Focus Stealing**: The keyboard appears as an overlay without disrupting your workflow
- **Persistent Controls**: The applet remains accessible even when the keyboard is hidden
- **Visual Feedback**: Clear status indicators and button states

## 🛠️ Components

- **wvkbd-mobintl**: The actual virtual keyboard (external dependency)
- **cosmic-virtual-keyboard**: The COSMIC panel applet (this project)
- **Desktop Integration**: Proper `.desktop` file for COSMIC panel discovery

## 📁 Project Structure

```
cosmic-virtual-keyboard/
├── src/
│   ├── main.rs           # Application entry point
│   ├── window.rs         # COSMIC applet implementation
│   └── lib.rs            # Library placeholder
├── Cargo.toml           # Rust dependencies
├── cosmic-virtual-keyboard.desktop  # Desktop entry for COSMIC
├── setup.sh             # Automated installation script
└── README.md            # This file
```

## 🎯 Installation

### COSMIC Store (Recommended)

🚀 **Coming Soon!** The easiest way to install this applet will be through the COSMIC Store:

1. Open **COSMIC Store**
2. Search for "Virtual Keyboard"
3. Click **Install**
4. Add to your panel via COSMIC Settings → Desktop → Panel

*Currently in development - see manual installation below for now.*

### Quick Setup (Manual)

Run the automated setup script:

```bash
chmod +x setup.sh
./setup.sh
```

### Manual Installation

1. **Install wvkbd**:
```bash
# Install dependencies
sudo apt update
sudo apt install build-essential pkg-config libwayland-dev libxkbcommon-dev

# Clone and build wvkbd
git clone https://github.com/jjsullivan5196/wvkbd.git
cd wvkbd
make
cp wvkbd-mobintl ~/.local/bin/
cd ..
```

2. **Build the COSMIC applet**:
```bash
# Build the applet
cargo build --release

# Install system-wide
sudo cp target/release/cosmic-virtual-keyboard /usr/bin/
sudo cp cosmic-virtual-keyboard.desktop /usr/share/applications/
```

3. **Add to COSMIC Panel**:
   - Open COSMIC Settings
   - Go to Desktop → Panel
   - Click "Add Applet" 
   - Select "Virtual Keyboard" from the list

## 🎮 Usage

### Basic Operation
1. **Click the keyboard icon** in your COSMIC panel to open the control popup
2. **Toggle On/Off**: Start or stop the virtual keyboard entirely
3. **Show/Hide**: Control visibility while keeping the keyboard process running
4. **Status Display**: See current keyboard state at a glance

### Keyboard Controls
- The virtual keyboard supports full QWERTY layout
- Click keys to type
- Supports modifier keys (Shift, Ctrl, Alt)
- Special keys (Enter, Backspace, Space) included

### Signal Management
The applet uses standard POSIX signals to control wvkbd:
- `SIGUSR1`: Hide the keyboard
- `SIGUSR2`: Show the keyboard  
- `SIGTERM`: Stop the keyboard process

## 🔧 Configuration

### wvkbd Configuration
The keyboard can be customized by modifying wvkbd options in `src/window.rs`:
```rust
std::process::Command::new("wvkbd-mobintl")
    .arg("-L")              // Height: 200px
    .arg("200")
    // Add more arguments as needed
```

### Desktop Entry
Modify `cosmic-virtual-keyboard.desktop` to change applet properties:
```ini
[Desktop Entry]
Name=Virtual Keyboard
Icon=input-keyboard-symbolic
X-CosmicApplet=true
# Other properties...
```

## 🐛 Troubleshooting

### Applet Not Appearing in Panel
- Ensure the `.desktop` file is in `/usr/share/applications/`
- Restart COSMIC or log out/in
- Check that `X-CosmicApplet=true` is set in the desktop entry

### Keyboard Not Starting  
- Verify `wvkbd-mobintl` is in your PATH: `which wvkbd-mobintl`
- Check process status: `pgrep wvkbd`
- Test manual start: `wvkbd-mobintl -L 200`

### Build Issues
- Ensure you have the COSMIC development environment set up
- Check Rust version: `rustc --version` (requires recent stable)
- Verify libcosmic dependencies are available

## 🏗️ Development

### Building from Source
```bash
# Debug build
cargo build

# Release build  
cargo build --release

# Run directly (for testing)
./target/debug/cosmic-virtual-keyboard
```

### Flatpak Development

For COSMIC Store distribution, the applet uses Flatpak:

```bash
# Generate cargo sources for offline build
./generate-cargo-sources.sh

# Build Flatpak (requires flatpak-builder)
flatpak-builder --user --install --force-clean build-dir com.cosmic.VirtualKeyboard.yml

# Run the Flatpak version
flatpak run com.cosmic.VirtualKeyboard
```

**Requirements for Flatpak building:**
- `flatpak-builder`
- `flatpak-builder-tools` (for cargo source generation)
- Freedesktop runtime and SDK

### Code Structure
- `main.rs`: Simple entry point that launches the applet
- `window.rs`: Complete COSMIC applet implementation with:
  - Application trait implementation
  - Message handling system
  - UI rendering (icon + popup)
  - Process management functions

### Dependencies
- **libcosmic**: COSMIC application framework
- **tokio**: Async runtime for process management
- **Standard library**: Process control and system calls

## 🤝 Contributing

Contributions are welcome! Areas where help is appreciated:
- UI/UX improvements
- Additional wvkbd layout options  
- Better error handling
- Documentation improvements

## 📄 License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **wvkbd**: [jjsullivan5196/wvkbd](https://github.com/jjsullivan5196/wvkbd) - The excellent virtual keyboard this project builds upon
- **COSMIC DE**: System76's desktop environment and libcosmic framework
- **Pop!_OS**: The target platform for this integration

## 📚 Related Projects

- [wvkbd](https://github.com/jjsullivan5196/wvkbd) - The virtual keyboard engine
- [libcosmic](https://github.com/pop-os/libcosmic) - COSMIC application framework  
- [COSMIC DE](https://github.com/pop-os/cosmic-epoch) - The desktop environment

---

**Made for COSMIC DE users who want simple, effective virtual keyboard control without the complexity!** 🚀