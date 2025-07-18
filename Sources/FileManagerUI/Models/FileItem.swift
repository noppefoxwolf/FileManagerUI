import Foundation
import UniformTypeIdentifiers

public struct FileItem: Identifiable, Hashable {
    public var id: String { url.path() }
    public let name: String
    public let url: URL
    public let isDirectory: Bool
    public let size: Int64?
    public let modificationDate: Date?
    public let isHidden: Bool
    public let contentType: UTType?

    public init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        self.isHidden = url.lastPathComponent.hasPrefix(".")

        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        self.isDirectory = exists && isDir.boolValue

        // Get content type
        if let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey]) {
            self.contentType = resourceValues.contentType
        } else {
            self.contentType = UTType(filenameExtension: url.pathExtension)
        }

        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) {
            self.size = attributes[.size] as? Int64
            self.modificationDate = attributes[.modificationDate] as? Date
        } else {
            self.size = nil
            self.modificationDate = nil
        }
    }

    var formattedDate: String {
        guard let date = modificationDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var formattedSize: String {
        guard let size = size else { return "" }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    var mimeType: String {
        return contentType?.preferredMIMEType ?? "Unknown"
    }

    var fileExtension: String {
        return url.pathExtension.isEmpty ? "No extension" : ".\(url.pathExtension)"
    }

    var typeDescription: String {
        return contentType?.localizedDescription ?? "Unknown file"
    }
}
