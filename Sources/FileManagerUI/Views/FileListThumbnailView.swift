import SwiftUI

struct FileListThumbnailView: View {
    let item: FileItem

    var body: some View {
        ThumbnailView(url: item.url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
        } placeholder: {
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
}
