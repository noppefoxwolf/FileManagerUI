# FileManagerUI

A SwiftUI file manager component for iOS apps with native design and QuickLook integration.

<img src=".github/example.png" alt="FileManagerUI Example" width="300">

## Features

- **File Navigation**: Browse directories with list/grid views
- **QuickLook Preview**: Tap files to preview with native QuickLook
- **File Operations**: Create, rename, delete, and share files
- **Multiple Selection**: Select multiple items for bulk operations
- **Hidden Files**: Toggle visibility with smooth animations
- **Error Handling**: Graceful permission and access error messages

## Installation

Add via Swift Package Manager in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/noppefoxwolf/FileManagerUI.git`

## Usage

```swift
import SwiftUI
import FileManagerUI

struct ContentView: View {
    var body: some View {
        FileManagerView()
    }
}
```

### Custom Path

```swift
FileManagerView(initialPath: customURL)
```

By default, starts from the app container directory.

## Requirements

- iOS 17.0+
- Swift 6.1+

## License

MIT License. See LICENSE file for details.