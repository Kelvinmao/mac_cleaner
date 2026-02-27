# MacCleaner

A lightweight and powerful macOS application for analyzing and cleaning up storage space on your Mac.

![MacCleaner](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Storage Analysis**: Visual breakdown of disk usage with interactive pie charts
- **Large File Scanner**: Find files larger than 10MB (configurable up to 1000MB)
- **Duplicate File Detector**: Smart duplicate detection with one-click cleanup
- **Cache Cleaner**: Clean system, user, application, browser caches and log files
- **Modern UI**: Built with SwiftUI for a native macOS experience

## Screenshots

![Storage Analysis](https://via.placeholder.com/800x600/1a1a2e/16213e?text=Storage+Analysis)
![Large Files](https://via.placeholder.com/800x600/1a1a2e/16213e?text=Large+Files+Scanner)
![Duplicates](https://via.placeholder.com/800x600/1a1a2e/16213e?text=Duplicate+Files+Detector)
![Cache Cleaner](https://via.placeholder.com/800x600/1a1a2e/16213e?text=Cache+Cleaner)

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon (M1/M2/M3) or Intel Mac with 64-bit support
- 4GB RAM minimum, 8GB recommended

## Installation

### Pre-built Binary

Download the latest release from the [Releases](https://github.com/yourusername/mac_cleaner/releases) page.

**Note**: Since this is an unsigned binary, you may need to:
1. Right-click `MacCleaner.app` and select "Open"
2. Click "Open" in the security dialog
3. Or run in Terminal: `xattr -cr MacCleaner.app && open MacCleaner.app`

### Build from Source

#### Prerequisites
- Xcode 15.0 or later, OR
- Swift 5.9 or later with Swift Package Manager

#### Build Steps

```bash
# Clone the repository
git clone https://github.com/yourusername/mac_cleaner.git
cd mac_cleaner

# Build the release version
swift build -c release

# Create .app bundle (optional)
./build_release.sh

# Run the app
./build/MacCleaner.app
```

### Using Xcode

```bash
# Open the project
open Package.swift

# Press Cmd+R to build and run
```

## Usage

### Storage Analysis

1. Click on the "Storage" tab in the sidebar
2. The app automatically analyzes your disk usage
3. View the breakdown by category (Home, Applications, System, Library, etc.)
4. Click the refresh button to re-analyze

### Large Files

1. Click on the "Large Files" tab
2. Adjust the minimum file size slider (10MB - 1000MB)
3. Click "Scan" to start scanning your home directory
4. Select files to delete
5. Click "Delete Selected" to remove them permanently

### Duplicate Files

1. Click on the "Duplicates" tab
2. Click "Scan" to find duplicate files using SHA256 hashing
3. Expand groups to see individual files
4. Click "Smart Select" to select all duplicate groups
5. Click "Delete Selected" - the first file in each group is kept, all others are deleted

### Cache Cleaner

1. Click on the "Cache" tab
2. Click "Scan" to find cache files
3. Filter by type (System, User, Application, Browser, Logs)
4. Select items to clean
5. Click "Clean Selected" to remove them

## Architecture

```
MacCleaner/
├── Sources/MacCleaner/
│   ├── MacCleanerApp.swift          # App entry point
│   ├── ContentView.swift            # Main navigation view
│   ├── Views/                       # SwiftUI views
│   │   ├── StorageView.swift        # Storage analysis UI
│   │   ├── LargeFilesView.swift     # Large files scanner UI
│   │   ├── DuplicateFilesView.swift # Duplicate finder UI
│   │   └── CacheView.swift          # Cache cleaner UI
│   ├── Models/                      # Data models
│   │   ├── FileModels.swift         # File-related models
│   │   └── StorageModels.swift      # Storage analysis models
│   ├── Services/                    # Core business logic
│   │   ├── LargeFileScanner.swift   # Large file scanning
│   │   ├── DuplicateFileDetector.swift # Duplicate detection
│   │   ├── CacheCleaner.swift       # Cache cleaning
│   │   └── StorageAnalyzer.swift    # Storage analysis
│   └── Info.plist                   # App permissions
├── Package.swift                    # Swift package definition
├── build_release.sh                 # Release build script
└── README.md
```

## Privacy & Security

- **Local Processing**: All file operations are performed locally on your Mac
- **No Network**: No data is sent to external servers
- **Transparent**: Open source code - you can review what the app does
- **Permissions**: Only requests necessary permissions for file access

### Required Permissions

- **Desktop Access**: To scan and clean files on your desktop
- **Documents Access**: To scan and clean files in your documents folder
- **Downloads Access**: To scan and clean files in your downloads folder
- **External Drives**: To scan and clean files on external drives

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/mac_cleaner.git
cd mac_cleaner

# Install dependencies (none required for this project)
# All dependencies are part of the Swift standard library

# Run tests (if any)
swift test

# Build in debug mode
swift build

# Build in release mode
swift build -c release
```

## Troubleshooting

### App won't open after download

**Solution**:
```bash
# Remove quarantine attributes
xattr -cr MacCleaner.app

# Open the app
open MacCleaner.app
```

### Permission denied errors

**Solution**:
1. Go to **System Settings** > **Privacy & Security**
2. Grant access to Desktop, Documents, and Downloads folders
3. Restart the app

### Scan is very slow

**Solution**:
- Large file scans can take time depending on your disk size
- Consider scanning specific folders instead of your entire home directory
- Try increasing the minimum file size threshold

### "Malware" warning

**Solution**: This is a security warning because the app is not signed by Apple. Right-click the app and select "Open", then click "Open" in the dialog.

## Known Limitations

- System-level cleaning requires sudo access (not included for security reasons)
- Some system files are protected by macOS SIP (System Integrity Protection)
- Large duplicate file detection can be time-consuming
- No automatic scheduling - manual cleanup only

## Roadmap

- [ ] Automatic scheduling of scans
- [ ] File preview before deletion
- [ ] Undo functionality for deleted files
- [ ] Custom scan locations
- [ ] Export scan results
- [ ] Dark mode optimization
- [ ] App signing and notarization for easy distribution

## Disclaimer

⚠️ **Warning**: This app permanently deletes files. Always review the files carefully before deleting. Consider backing up important data before performing cleanup operations.

**Use at your own risk**. The authors are not responsible for any data loss or damage that may occur while using this application.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Swift](https://swift.org) and [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Powered by [Swift Package Manager](https://swift.org/package-manager/)
- Inspired by various macOS cleaning utilities

## Contact

For issues, questions, or suggestions:
- Open an issue on [GitHub](https://github.com/yourusername/mac_cleaner/issues)
- Pull requests are welcome!

---

**Made with ❤️ for Mac users**