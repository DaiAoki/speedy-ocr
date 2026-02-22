import Foundation

/// Formats OCR results as plain text.
/// Pages are separated by blank lines. Empty pages are skipped.
public struct PlainTextFormatter: OutputFormatter {
    public init() {}

    public func format(result: OCRResult) -> String {
        result.processedPages
            .filter { !$0.text.isEmpty }
            .map { $0.text }
            .joined(separator: "\n\n")
    }
}
