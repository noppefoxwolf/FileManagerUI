import QuickLook
import QuickLookThumbnailing
import SwiftUI

struct FileListThumbnailView: View {
    let item: FileItem
    @State private var thumbnail: UIImage?
    @State private var isLoading = false
    @Environment(\.displayScale)
    var displayScale

    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
            } else {
                Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                    .foregroundColor(item.isHidden ? .gray : (item.isDirectory ? .blue : .gray))
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        guard !item.isDirectory, !isLoading else { return }

        isLoading = true
        let request = QLThumbnailGenerator.Request(
            fileAt: item.url,
            size: CGSize(width: 120, height: 120),
            scale: displayScale,
            representationTypes: .thumbnail
        )

        Task {
            do {
                let generator = QLThumbnailGenerator.shared
                let representation = try await generator.generateBestRepresentation(
                        for: request
                    )
                isLoading = false
                thumbnail = representation.uiImage
            } catch {
                isLoading = false
            }
        }
    }
}
