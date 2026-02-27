#!/bin/bash

set -e

APP_NAME="MacCleaner"
VERSION="1.0.0"
BUILD_DIR="build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS="${CONTENTS}/MacOS"
RESOURCES="${CONTENTS}/Resources"

echo "🔨 Building ${APP_NAME} v${VERSION}..."

# 清理旧的构建
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# 构建release版本
echo "📦 Building release binary..."
swift build -c release --product MacCleaner

# 获取架构
ARCH=$(uname -m)
BINARY_PATH=".build/${ARCH}-apple-macosx/release/MacCleaner"

# 创建.app bundle结构
echo "📁 Creating .app bundle..."
mkdir -p "${MACOS}"
mkdir -p "${RESOURCES}"

# 复制二进制文件
echo "📋 Copying binary..."
cp "${BINARY_PATH}" "${MACOS}/${APP_NAME}"
chmod +x "${MACOS}/${APP_NAME}"

# 创建Info.plist
echo "📝 Creating Info.plist..."
cat > "${CONTENTS}/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en_US</string>
    <key>CFBundleExecutable</key>
    <string>MacCleaner</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.MacCleaner</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>MacCleaner</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSDesktopFolderUsageDescription</key>
    <string>MacCleaner needs access to scan and clean files on your desktop.</string>
    <key>NSDocumentsFolderUsageDescription</key>
    <string>MacCleaner needs access to scan and clean files in your documents folder.</string>
    <key>NSDownloadsFolderUsageDescription</key>
    <string>MacCleaner needs access to scan and clean files in your downloads folder.</string>
    <key>NSRemovableVolumesUsageDescription</key>
    <string>MacCleaner needs access to scan and clean files on external drives.</string>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>
</dict>
</plist>
EOF

# 设置图标（可选，需要.icns文件）
# cp "MacCleaner.icns" "${RESOURCES}/AppIcon.icns"

echo "✅ Build complete!"
echo ""
echo "📦 .app bundle created: ${APP_BUNDLE}"
echo ""
echo "🚀 To run:"
echo "   open \"${APP_BUNDLE}\""
echo ""
echo "📦 To create distributable zip:"
echo "   ditto -c -k --keepParent \"${APP_BUNDLE}\" \"${BUILD_DIR}/${APP_NAME}-v${VERSION}.zip\""
echo ""
echo "ℹ️  Note: This is an unsigned binary. Users will need to:"
echo "   1. Right-click the app and select 'Open'"
echo "   2. Click 'Open' in the security dialog"
echo "   Or run in Terminal: xattr -cr \"${APP_BUNDLE}\" && open \"${APP_BUNDLE}\""