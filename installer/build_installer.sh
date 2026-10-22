#!/bin/bash
#
# Build the HMW A321neo macOS installer.
#
#   ./installer/build_installer.sh
#
# Produces:
#   HMW_A321neo_Installer.pkg   - macOS installer package (installs the .app)
#   HMW_A321neo_Installer.app   - standalone installer application
#
# The installer application downloads the aircraft from GitHub at run time, so
# the package itself stays small and always delivers the latest main branch.
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
BUILD="$HERE/build"
APP="$BUILD/HMW_A321neo_Installer.app"

echo "==> Cleaning build directory"
rm -rf "$BUILD"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

echo "==> Assembling application bundle"
cp "$HERE/HMW_A321neo_Installer.sh" "$APP/Contents/MacOS/HMW_A321neo_Installer"
chmod +x "$APP/Contents/MacOS/HMW_A321neo_Installer"

cat > "$APP/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>HMW A321neo Installer</string>
    <key>CFBundleDisplayName</key>
    <string>HMW A321neo Installer</string>
    <key>CFBundleExecutable</key>
    <string>HMW_A321neo_Installer</string>
    <key>CFBundleIdentifier</key>
    <string>com.hmwa321neo.installer</string>
    <key>CFBundleIconFile</key>
    <string>HMW_A321neo_Installer.icns</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>HoldMyWire. Aircraft assets CC BY-NC-SA 4.0. A321_Mod gear GPL v2. A32NX sounds CC BY-NC-SA 4.0.</string>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
    <key>NSSupportsSuddenTermination</key>
    <false/>
    <key>NSAppleEventsUsageDescription</key>
    <string>HMW A321neo Installer needs Automation access to display install progress dialogs.</string>
</dict>
</plist>
PLIST

printf 'APPL????' > "$APP/Contents/PkgInfo"

cp "$HERE/resources/background.png" "$APP/Contents/Resources/background.png"
cp "$HERE/resources/icon.icns" "$APP/Contents/Resources/HMW_A321neo_Installer.icns"

echo "==> Validating application bundle"
plutil -lint "$APP/Contents/Info.plist" > /dev/null
bash -n "$APP/Contents/MacOS/HMW_A321neo_Installer"

echo "==> Building component package"
cd "$BUILD"
pkgbuild --root . --install-location /Applications \
         --identifier "com.hmwa321neo.installer" \
         --version "1.0.0" \
         "HMW_A321neo_Installer.pkg"

echo "==> Building distribution package (with background and welcome screen)"
productbuild --distribution "$HERE/Distribution.xml" \
              --package-path . \
              --resources "$HERE/resources" \
              "HMW_A321neo_Installer_Final.pkg"

echo ""
echo "==> Build complete"
ls -la "$BUILD/HMW_A321neo_Installer_Final.pkg"
echo ""
echo "    Copy to Desktop with:"
echo "      cp '$BUILD/HMW_A321neo_Installer_Final.pkg' ~/Desktop/HMW_A321neo_Installer.pkg"
echo "      cp -R '$APP' ~/Desktop/HMW_A321neo_Installer.app"
