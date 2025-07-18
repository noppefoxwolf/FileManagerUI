import Foundation

public struct DirectoryInfo {
    public let path: String
    public let creationDate: Date?
    public let modificationDate: Date?
    public let directoryCount: Int
    public let fileCount: Int
    public let totalSize: Int64

    public var formattedCreationDate: String {
        guard let date = creationDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    public var formattedModificationDate: String {
        guard let date = modificationDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    public var formattedTotalSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSize)
    }
}
