import SwiftUI

struct FileItemRow: View {
    let item: FileItem

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .foregroundColor(item.isHidden ? .gray : .primary)

                HStack(spacing: 8) {
                    if let date = item.modificationDate {
                        Text(item.formattedDate)
                            .font(.caption)
                            .foregroundColor(item.isHidden ? .gray : .secondary)
                    }

                    if !item.isDirectory, let size = item.size {
                        Text(item.formattedSize)
                            .font(.caption)
                            .foregroundColor(item.isHidden ? .gray : .secondary)
                    }
                }
            }
        } icon: {
            FileListThumbnailView(item: item)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}
