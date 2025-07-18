import Foundation
import QuickLook
import QuickLookThumbnailing
import SwiftUI
import UIKit
import UniformTypeIdentifiers

public struct FileManagerView: View {
    let initialPath: URL
    let fileManager: FileManager
    @State private var navigationPath = NavigationPath()

    public init(
        initialPath: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.initialPath =
            initialPath ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .deletingLastPathComponent()
            ?? URL(fileURLWithPath: "/")
        self.fileManager = fileManager
    }

    private var appContainerURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .deletingLastPathComponent()
            ?? URL(fileURLWithPath: "/")
    }

    private func setupInitialPath() {
        let components = pathComponents(for: initialPath)

        // Skip the root path and add the rest to navigation path
        for i in 1..<components.count {
            navigationPath.append(components[i])
        }
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            DirectoryContentView(path: initialPath, fileManager: fileManager)
                .navigationDestination(for: URL.self) { url in
                    DirectoryContentView(path: url, fileManager: fileManager)
                }
        }
        .onAppear {
            setupInitialPath()
        }
        .onReceive(NotificationCenter.default.publisher(for: .jumpToAppContainer)) { _ in
            jumpToAppContainer()
        }
    }

    private func jumpToAppContainer() {
        // Clear current navigation path
        navigationPath = NavigationPath()

        // Build path to app container
        let containerComponents = pathComponents(for: appContainerURL)

        // Skip the root path and add the rest to navigation path
        for i in 1..<containerComponents.count {
            navigationPath.append(containerComponents[i])
        }
    }

    private func pathComponents(for url: URL) -> [URL] {
        var components: [URL] = []
        var currentURL = url

        while currentURL.path != "/" {
            components.insert(currentURL, at: 0)
            currentURL = currentURL.deletingLastPathComponent()
        }

        components.insert(URL(fileURLWithPath: "/"), at: 0)
        return components
    }
}
