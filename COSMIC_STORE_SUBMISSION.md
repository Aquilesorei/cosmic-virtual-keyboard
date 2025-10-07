# COSMIC Store Submission Guide

This guide explains how to submit Spaceboard to the COSMIC Store.

## Prerequisites

1. **Complete the app**: Ensure all functionality is working correctly
2. **Take screenshots**: High-quality screenshots for the store listing
3. **Test Flatpak build**: Verify the Flatpak version works properly
4. **Update metadata**: Ensure all URLs and contact info are correct

## Files Required for Submission

### Core Flatpak Files
- `io.github.aquilesorei.Spaceboard.json` - Flatpak manifest
- `io.github.aquilesorei.Spaceboard.appdata.xml` - AppStream metadata
- `spaceboard.desktop` - Desktop entry
- `cargo-sources.json` - Generated cargo dependencies (run `./generate-cargo-sources.sh`)

### Assets
- `icons/hicolor/scalable/apps/input-keyboard-symbolic.svg` - App icon (mapped to io.github.aquilesorei.Spaceboard)
- `screenshots/` - High-quality screenshots for store listing
  - `panel-icon.png`
  - `popup-controls.png` 
  - `keyboard-shown.png`

## Submission Steps

### 1. Prepare Screenshots
Take high-quality screenshots showing:
- The keyboard icon in the COSMIC panel
- The control popup interface
- The virtual keyboard in use

Screenshots should be:
- PNG format
- At least 1280x720 resolution
- Clean and professional looking

### 2. Update Contact Information
Before submitting, update the following files with your actual information:
- `io.github.aquilesorei.Spaceboard.appdata.xml`: Update developer name, email, and URLs
- `README.md`: Update GitHub URLs if hosting elsewhere

### 3. Test Flatpak Build
```bash
# Generate cargo sources
./generate-cargo-sources.sh

# Build and test
flatpak-builder --user --install --force-clean build-dir io.github.aquilesorei.Spaceboard.json

# Test the installed version
flatpak run io.github.aquilesorei.Spaceboard
```

### 4. Submit to COSMIC Store
The COSMIC Store submission process typically involves:

1. **Fork the COSMIC Store repository** (when available)
2. **Add your app manifest** to the appropriate directory
3. **Include all required files** (manifest, appdata, icon, screenshots)
4. **Create a pull request** with your submission

## Submission Checklist

- [ ] App builds successfully with Flatpak
- [ ] All functionality works in Flatpak version
- [ ] Screenshots are high quality and representative
- [ ] AppStream metadata is complete and accurate
- [ ] Desktop entry follows standards
- [ ] Icon is provided in SVG format
- [ ] All URLs and contact info are updated
- [ ] App follows COSMIC design guidelines
- [ ] Dependencies are properly declared

## App Store Metadata

### Categories
- Utility
- Accessibility  
- System

### Keywords
- virtual keyboard
- accessibility
- input
- touch
- panel applet
- COSMIC

### Description
Emphasize:
- Native COSMIC integration
- Accessibility benefits
- Easy-to-use interface
- Reliable wvkbd backend

## Post-Submission

After submission:
1. **Monitor for feedback** from COSMIC Store maintainers
2. **Address any issues** or requested changes
3. **Update as needed** based on review comments
4. **Maintain the app** with bug fixes and improvements

## Notes

- The COSMIC Store is still in development, so this process may change
- Check the official COSMIC documentation for the latest submission guidelines
- Consider joining the COSMIC community for support and updates

## Contact

For questions about the submission process, reach out to:
- COSMIC DE community forums
- System76 support channels
- COSMIC development Discord/Matrix