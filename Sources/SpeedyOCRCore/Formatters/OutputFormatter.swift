import Foundation

/// Protocol for formatting OCR results into different output formats.
public protocol OutputFormatter {
    func format(result: OCRResult) -> String
}

/// Create a formatter for the given output format.
public func makeFormatter(for format: OutputFormat) -> OutputFormatter {
    switch format {
    case .txt:
        return PlainTextFormatter()
    case .md:
        return MarkdownFormatter()
    case .json:
        return JSONFormatter()
    }
}
