import QuickLook
import QuickLookThumbnailing
import SwiftUI
import UIKit

struct FileGridThumbnailView: View {
    let item: FileItem
    @State private var thumbnail: UIImage?
    @State private var isLoading = false

    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
            } else {
                Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                    .foregroundColor(item.isHidden ? .gray : (item.isDirectory ? .blue : .gray))
                    .font(.system(size: 32))
                    .frame(width: 60, height: 60)
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
            scale: UIScreen.main.scale,
            representationTypes: .thumbnail
        )

        Task {
            do {
                let representation = try await QLThumbnailGenerator.shared
                    .generateBestRepresentation(
                        for: request
                    )
                await MainActor.run {
                    isLoading = false
                    thumbnail = representation.uiImage
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}
