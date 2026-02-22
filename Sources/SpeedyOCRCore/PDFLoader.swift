import CoreGraphics
import Foundation

/// Loads and validates PDF documents.
public struct PDFLoader {
    public init() {}

    /// Load a PDF document from the given file path.
    public func load(path: String) throws -> CGPDFDocument {
        let url = URL(fileURLWithPath: path)

        guard FileManager.default.fileExists(atPath: path) else {
            throw PDFLoaderError.fileNotFound(path)
        }

        guard let document = CGPDFDocument(url as CFURL) else {
            throw PDFLoaderError.invalidPDF(path)
        }

        guard document.numberOfPages > 0 else {
            throw PDFLoaderError.emptyPDF(path)
        }

        return document
    }
}

public enum PDFLoaderError: LocalizedError {
    case fileNotFound(String)
    case invalidPDF(String)
    case emptyPDF(String)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .invalidPDF(let path):
            return "Cannot open PDF file: \(path)"
        case .emptyPDF(let path):
            return "PDF has no pages: \(path)"
        }
    }
}
