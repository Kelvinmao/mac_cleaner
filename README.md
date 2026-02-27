# MacCleaner

A powerful macOS application for analyzing and cleaning up storage space on your Mac.

## Features

- **Storage Analysis**: Visual breakdown of disk usage with pie charts and category analysis
- **Large File Scanner**: Find files larger than 100MB (configurable) that are taking up space
- **Duplicate File Detector**: Identify and remove duplicate files to reclaim wasted space
- **Cache Cleaner**: Clean system, user, application, browser caches and log files

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Building

### Using Swift Package Manager

```bash
swift build
swift run MacCleaner
```

### Using Xcode

1. Open `Package.swift` in Xcode
2. Select the MacCleaner scheme
3. Press Cmd+R to build and run

## Usage

### Storage Analysis

1. Click on the "Storage" tab
2. The app will automatically analyze your disk usage
3. View the breakdown by category (Home, Applications, System, Library, etc.)
4. Click "Refresh" to re-analyze

### Large Files

1. Click on the "Large Files" tab
2. Adjust the minimum file size slider (10MB - 1000MB)
3. Click "Scan" to start scanning
4. Select files to delete
5. Click "Delete Selected" to remove them

### Duplicate Files

1. Click on the "Duplicates" tab
2. Click "Scan" to find duplicate files
3. Expand groups to see individual files
4. Select groups to delete (keeps the first file in each group)
5. Click "Delete Selected" to remove duplicates

### Cache Cleaner

1. Click on the "Cache" tab
2. Click "Scan" to find cache files
3. Filter by type (System, User, Application, Browser, Logs)
4. Select items to clean
5. Click "Clean Selected" to remove them

## Privacy & Permissions

MacCleaner requires the following permissions:

- **Desktop Access**: To scan and clean files on your desktop
- **Documents Access**: To scan and clean files in your documents folder
- **Downloads Access**: To scan and clean files in your downloads folder
- **External Drives**: To scan and clean files on external drives

All file operations are performed locally on your Mac. No data is sent to external servers.

## Warning

⚠️ **Important**: This app permanently deletes files. Always review the files carefully before deleting. Consider backing up important data before performing cleanup operations.

## Project Structure

```
MacCleaner/
├── Sources/MacCleaner/
│   ├── MacCleanerApp.swift          # App entry point
│   ├── ContentView.swift            # Main navigation view
│   ├── Views/
│   │   ├── StorageView.swift        # Storage analysis UI
│   │   ├── LargeFilesView.swift     # Large files scanner UI
│   │   ├── DuplicateFilesView.swift # Duplicate finder UI
│   │   └── CacheView.swift          # Cache cleaner UI
│   ├── Models/
│   │   ├── FileModels.swift         # File-related data models
│   │   └── StorageModels.swift      # Storage analysis models
│   ├── Services/
│   │   ├── LargeFileScanner.swift   # Large file scanning logic
│   │   ├── DuplicateFileDetector.swift # Duplicate detection logic
│   │   ├── CacheCleaner.swift       # Cache cleaning logic
│   │   └── StorageAnalyzer.swift    # Storage analysis logic
│   └── Info.plist                   # App permissions and metadata
└── Package.swift                    # Swift package definition
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is provided as-is for educational purposes. Use at your own risk.

## Disclaimer

This software is provided without warranty of any kind. The authors are not responsible for any data loss or damage that may occur while using this application. Always backup your important data before performing any cleanup operations.