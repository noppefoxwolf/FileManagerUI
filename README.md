# FileManagerUI

A SwiftUI-based file manager component for iOS apps that provides a native file browsing experience with modern UI design.

## Features

### 📁 File System Navigation
- Navigate through directories with standard iOS navigation patterns
- Support for both list and grid view modes
- Breadcrumb navigation with NavigationStack
- Jump to app container functionality

### 🖼️ Rich File Preview
- QuickLook integration for file previews
- Thumbnail generation for images and documents
- Consistent thumbnail display across list and grid views
- Tap to preview files in QuickLook

### 👁️ Hidden Files Support
- Toggle hidden files visibility with smooth animations
- Files are loaded once and filtered dynamically for performance
- Hidden files displayed with visual distinction (grayed out)

### ✏️ File Operations
- Create new files and directories
- Rename files and directories
- Delete single or multiple files
- Share files using system share sheet
- Context menus for quick actions

### 📱 Multiple Selection
- Edit mode for selecting multiple items
- Visual selection indicators
- Bulk operations (delete, share) on selected items
- Clear selection count display

### 🎨 Modern UI Design
- Native iOS design language
- Smooth animations and transitions
- Consistent styling across components
- Responsive layout for different screen sizes
- Fine-tuned spacing and typography

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/noppefoxwolf/FileManagerUI.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/noppefoxwolf/FileManagerUI.git`

## Usage

### Basic Implementation

```swift
import SwiftUI
import FileManagerUI

struct ContentView: View {
    var body: some View {
        FileManagerView()
    }
}
```

### Custom Initial Path

```swift
FileManagerView(
    initialPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
)
```

### Custom FileManager

```swift
FileManagerView(
    initialPath: customURL,
    fileManager: customFileManager
)
```

### Navigation Integration

```swift
NavigationView {
    FileManagerView(initialPath: customURL)
}
```

## Architecture

### Core Components

- **FileManagerView**: Main container view with navigation handling
- **DirectoryContentView**: Displays directory contents with list/grid modes
- **DirectoryStore**: Observable data store for file operations
- **FileItem**: Model representing file system items
- **FileListThumbnailView**: Handles thumbnail generation for list mode
- **FileGridThumbnailView**: Handles thumbnail generation for grid mode

### View Hierarchy

```
FileManagerView
├── NavigationStack
│   └── DirectoryContentView
│       ├── FileItemRow (List Mode)
│       │   └── FileListThumbnailView
│       └── FileItemGridCell (Grid Mode)
│           └── FileGridThumbnailView
```

## Customization

### FileManager Support

The component supports custom FileManager instances, useful for:
- Testing with mock file systems
- Sandboxed environments
- Custom file operations

```swift
// Using a custom FileManager
let customFileManager = FileManager()
FileManagerView(
    initialPath: customPath,
    fileManager: customFileManager
)
```

### View Modes
- **List View**: Detailed file information with large thumbnails (54x54px)
- **Grid View**: Compact grid layout with thumbnails (60x60px)

### Toolbar Actions
- View mode toggle (list/grid)
- Hidden files visibility toggle
- File creation (folders and files)
- Navigation to app container
- Edit mode toggle
- Refresh functionality

### Selection Mode
- Multiple item selection
- Bulk delete operations
- Bulk share operations
- Visual selection feedback

## Requirements

- iOS 15.0+
- Swift 5.7+
- Xcode 14.0+

## Permissions

The component requires access to the file system. Make sure your app has appropriate permissions for the directories you want to browse.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License. See LICENSE file for details.