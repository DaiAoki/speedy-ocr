import Foundation

/// Formats OCR results as JSON.
public struct JSONFormatter: OutputFormatter {
    public init() {}

    public func format(result: OCRResult) -> String {
        let metadata: [String: Any] = [
            "source": result.sourceFileName,
            "totalPages": result.totalPages,
            "processedPages": result.processedPages.count,
            "dpi": result.dpi,
            "languages": result.languages,
            "elapsedSeconds": (result.elapsedSeconds * 10).rounded() / 10,
        ]

        let pages: [[String: Any]] = result.processedPages.map { page in
            ["page": page.pageNumber, "text": page.text]
        }

        let json: [String: Any] = [
            "metadata": metadata,
            "pages": pages,
        ]

        guard let data = try? JSONSerialization.data(
            withJSONObject: json,
            options: [.prettyPrinted, .sortedKeys]
        ),
            let string = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }

        return string
    }
}
