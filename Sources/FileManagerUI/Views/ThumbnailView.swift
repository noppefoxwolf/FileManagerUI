import SwiftUI

struct ThumbnailView<Content: View, Placeholder: View>: View {
    let url: URL
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State
    var viewModel = ThumbnailViewModel()
    
    @Environment(\.displayScale)
    var displayScale
    
    init(
        url: URL,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let thumbnail = viewModel.thumbnail {
                content(thumbnail)
            } else {
                placeholder()
            }
        }
        .task {
            await viewModel.loadThumbnail(at: url, scale: displayScale, representationTypes: [.icon, .thumbnail])
        }
    }
}
