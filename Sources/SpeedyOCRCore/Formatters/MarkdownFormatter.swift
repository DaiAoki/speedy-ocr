import Foundation

/// Formats OCR results as Markdown with page headings.
public struct MarkdownFormatter: OutputFormatter {
    public init() {}

    public func format(result: OCRResult) -> String {
        var lines: [String] = []

        let title = (result.sourceFileName as NSString).deletingPathExtension
        lines.append("# \(title)")
        lines.append("")

        for page in result.processedPages {
            lines.append("## Page \(page.pageNumber)")
            lines.append("")
            if !page.text.isEmpty {
                lines.append(page.text)
                lines.append("")
            }
        }

        return lines.joined(separator: "\n")
    }
}
