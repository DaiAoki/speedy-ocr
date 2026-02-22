import CoreGraphics
import Foundation

/// Renders PDF pages to CGImage at a specified DPI.
public struct PageRenderer {
    private let dpi: Int

    public init(dpi: Int = 150) {
        self.dpi = dpi
    }

    /// Render a PDF page to a CGImage.
    public func render(page: CGPDFPage) throws -> CGImage {
        let scaleFactor = CGFloat(dpi) / 72.0
        let mediaBox = page.getBoxRect(.mediaBox)
        let width = Int(mediaBox.width * scaleFactor)
        let height = Int(mediaBox.height * scaleFactor)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw PageRendererError.contextCreationFailed
        }

        // Fill white background
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Scale and draw PDF page
        context.scaleBy(x: scaleFactor, y: scaleFactor)
        context.drawPDFPage(page)

        guard let image = context.makeImage() else {
            throw PageRendererError.renderFailed
        }

        return image
    }
}

public enum PageRendererError: LocalizedError {
    case contextCreationFailed
    case renderFailed

    public var errorDescription: String? {
        switch self {
        case .contextCreationFailed:
            return "Failed to create graphics context for page rendering"
        case .renderFailed:
            return "Failed to render page to image"
        }
    }
}
