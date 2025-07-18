import Foundation
import Observation

@MainActor
@Observable
public class DirectoryStore {
    private var allItems: [FileItem] = []
    public var isLoading = false
    public var directoryInfo: DirectoryInfo?
    public var showHiddenFiles = false
    public var error: Error?

    public var items: [FileItem] {
        if showHiddenFiles {
            return allItems
        } else {
            return allItems.filter { !$0.name.hasPrefix(".") }
        }
    }

    public let currentPath: URL
    public let fileManager: FileManager

    public init(
        path: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.currentPath =
            path
            ?? (fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
                .deletingLastPathComponent()
                ?? URL(fileURLWithPath: "/"))
        self.fileManager = fileManager
        loadItems()
        loadDirectoryInfo()
    }

    public func refresh() {
        loadItems()
        loadDirectoryInfo()
    }

    public func toggleHiddenFiles() {
        showHiddenFiles.toggle()
        loadDirectoryInfo()
    }

    public func createDirectory(name: String) throws {
        let newURL = currentPath.appendingPathComponent(name)
        try fileManager.createDirectory(at: newURL, withIntermediateDirectories: false)
        refresh()
    }

    public func createFile(name: String) throws {
        let newURL = currentPath.appendingPathComponent(name)
        fileManager.createFile(atPath: newURL.path, contents: Data(), attributes: nil)
        refresh()
    }

    public func deleteItems(withIDs ids: Set<FileItem.ID>) {
        for id in ids {
            if let item = allItems.first(where: { $0.id == id }) {
                try? fileManager.removeItem(at: item.url)
            }
        }
        refresh()
    }

    public func renameItem(at url: URL, newName: String) throws {
        let newURL = url.deletingLastPathComponent().appendingPathComponent(newName)
        try fileManager.moveItem(at: url, to: newURL)
        refresh()
    }

    private func loadItems() {
        isLoading = true
        error = nil

        Task {
            do {
                let urls = try fileManager.contentsOfDirectory(
                    at: self.currentPath,
                    includingPropertiesForKeys: [
                        .isDirectoryKey, .fileSizeKey, .contentModificationDateKey,
                    ],
                    options: []
                )

                let fileItems = urls.map { FileItem(url: $0) }
                    .sorted { first, second in
                        if first.isDirectory != second.isDirectory {
                            return first.isDirectory
                        }
                        return first.name.localizedCaseInsensitiveCompare(second.name)
                            == .orderedAscending
                    }

                self.allItems = fileItems
                self.error = nil
                self.isLoading = false
            } catch {
                self.allItems = []
                self.error = error
                self.isLoading = false
            }
        }
    }

    private func loadDirectoryInfo() {
        Task {
            do {
                let attributes = try fileManager.attributesOfItem(atPath: currentPath.path)
                let creationDate = attributes[.creationDate] as? Date
                let modificationDate = attributes[.modificationDate] as? Date

                let directoryCount = items.filter { $0.isDirectory }.count
                let fileCount = items.filter { !$0.isDirectory }.count
                let totalSize = items.compactMap { $0.size }.reduce(0, +)

                self.directoryInfo = DirectoryInfo(
                    path: currentPath.path,
                    creationDate: creationDate,
                    modificationDate: modificationDate,
                    directoryCount: directoryCount,
                    fileCount: fileCount,
                    totalSize: totalSize
                )
            } catch {
                self.directoryInfo = nil
            }
        }
    }
}
