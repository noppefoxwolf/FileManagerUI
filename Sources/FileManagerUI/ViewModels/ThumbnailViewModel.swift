import Foundation
import QuickLook
import QuickLookThumbnailing
import SwiftUI
import os

@MainActor
@Observable
final class ThumbnailViewModel {
    var thumbnail: Image?
    var isLoading = false
    
    let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier!, category: #file)
    
    func loadThumbnail(
        at url: URL,
        size: CGSize = CGSize(width: 256, height: 256),
        scale: CGFloat,
        representationTypes: QLThumbnailGenerator.Request.RepresentationTypes = .thumbnail
    ) async {
        guard !isLoading else { return }
        
        isLoading = true
        var request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: scale,
            representationTypes: representationTypes
        )
        
        do {
            let generator = QLThumbnailGenerator.shared
            let representation = try await generator.generateBestRepresentation(for: request)
            thumbnail = Image(uiImage: representation.uiImage)
            isLoading = false
        } catch {
            logger.error("Failed to generate thumbnail: \(error.localizedDescription)")
            isLoading = false
        }
    }
}

#if swift(<6.2)
extension QLThumbnailRepresentation: @unchecked Sendable {}
#endif
