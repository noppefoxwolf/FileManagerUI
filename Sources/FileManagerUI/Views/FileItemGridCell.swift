import SwiftUI

struct FileItemGridCell: View {
    let item: FileItem
    let isSelected: Bool
    let isEditMode: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                FileGridThumbnailView(item: item)

                if isEditMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: 8, y: -8)
                }
            }

            Text(item.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(item.isHidden ? .gray : .primary)
                .frame(maxWidth: .infinity)
        }
        .frame(minHeight: 100, alignment: .top)  // Fixed height for consistent grid layout
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .contentShape(RoundedRectangle(cornerRadius: 8))
    }
}
