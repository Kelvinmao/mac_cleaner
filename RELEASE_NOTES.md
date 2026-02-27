# MacCleaner v1.0.0 - Release

## 📦 Download

The latest release is available as `MacCleaner-v1.0.0.zip` (257KB)

## 🚀 Installation

### Method 1: Direct Install (Recommended)
1. Download `MacCleaner-v1.0.0.zip`
2. Unzip the file
3. Double-click `MacCleaner.app` to run
4. If you see a security warning, right-click the app and select "Open"

### Method 2: Command Line Install
```bash
# Remove quarantine attributes
xattr -cr MacCleaner.app

# Open the app
open MacCleaner.app
```

## ⚙️ System Requirements

- macOS 13.0 or later
- Apple Silicon (M1/M2/M3) or Intel Mac

## 🎯 Features

- **Storage Analysis**: Visual breakdown of disk usage
- **Large File Scanner**: Find files > 10MB (configurable)
- **Duplicate File Detector**: Smart duplicate detection with one-click cleanup
- **Cache Cleaner**: Clean system, user, app, browser caches

## 🔧 Usage

### Storage Analysis
1. Click "Storage" tab
2. View disk usage by category
3. Refresh anytime with the refresh button

### Large Files
1. Click "Large Files" tab
2. Adjust minimum size slider (10-1000MB)
3. Click "Scan"
4. Select files and click "Delete Selected"

### Duplicate Files
1. Click "Duplicates" tab
2. Click "Scan"
3. Click "Smart Select" to select all duplicate groups
4. Click "Delete Selected" - keeps first file in each group

### Cache Cleaner
1. Click "Cache" tab
2. Click "Scan"
3. Filter by type (System, User, App, Browser, Logs)
4. Select items and click "Clean Selected"

## ⚠️ Important Notes

- **Back up important data before cleaning**
- This app permanently deletes files
- Some system files require sudo access (not included in this version)
- The app is unsigned - you may need to allow it in System Settings > Privacy & Security

## 🛡️ Privacy

- All operations are performed locally on your Mac
- No data is sent to external servers
- File access is limited to your user directory and common cache locations

## 🐛 Troubleshooting

### App won't open
```bash
# Remove quarantine
xattr -cr MacCleaner.app
# Try again
open MacCleaner.app
```

### Permission denied
- Go to System Settings > Privacy & Security
- Grant access to Desktop, Documents, and Downloads folders

### Scan is slow
- Large file scans can take time
- Try scanning a specific folder instead of your entire home directory

## 📝 Building from Source

```bash
# Clone or download source
cd mac_cleaner

# Build
swift build -c release

# Create .app bundle
./build_release.sh
```

## 📄 License

This is a lightweight, open-source Mac cleaning tool. Use at your own risk.

## 🙏 Acknowledgments

Built with Swift and SwiftUI, powered by Swift Package Manager.