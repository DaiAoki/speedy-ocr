import Foundation
import Testing

@testable import SpeedyOCRCore

@Suite("Formatter Tests")
struct FormatterTests {
    let sampleResult = OCRResult(
        sourceFileName: "test.pdf",
        totalPages: 3,
        processedPages: [
            PageResult(pageNumber: 1, text: "Hello World"),
            PageResult(pageNumber: 2, text: "Page two content"),
            PageResult(pageNumber: 3, text: ""),
        ],
        dpi: 150,
        languages: ["en"],
        elapsedSeconds: 1.5
    )

    @Test("PlainTextFormatter joins non-empty pages with blank lines")
    func plainTextFormat() {
        let formatter = PlainTextFormatter()
        let output = formatter.format(result: sampleResult)

        #expect(output == "Hello World\n\nPage two content")
    }

    @Test("PlainTextFormatter skips empty pages")
    func plainTextSkipsEmpty() {
        let formatter = PlainTextFormatter()
        let output = formatter.format(result: sampleResult)

        #expect(!output.contains("Page 3"))
        #expect(output.components(separatedBy: "\n\n").count == 2)
    }

    @Test("MarkdownFormatter includes title and page headings")
    func markdownFormat() {
        let formatter = MarkdownFormatter()
        let output = formatter.format(result: sampleResult)

        #expect(output.contains("# test"))
        #expect(output.contains("## Page 1"))
        #expect(output.contains("## Page 2"))
        #expect(output.contains("## Page 3"))
        #expect(output.contains("Hello World"))
    }

    @Test("JSONFormatter produces valid JSON with metadata")
    func jsonFormat() throws {
        let formatter = JSONFormatter()
        let output = formatter.format(result: sampleResult)

        let data = output.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        let metadata = json["metadata"] as! [String: Any]
        #expect(metadata["source"] as! String == "test.pdf")
        #expect(metadata["totalPages"] as! Int == 3)
        #expect(metadata["processedPages"] as! Int == 3)
        #expect(metadata["dpi"] as! Int == 150)

        let pages = json["pages"] as! [[String: Any]]
        #expect(pages.count == 3)
        #expect(pages[0]["page"] as! Int == 1)
        #expect(pages[0]["text"] as! String == "Hello World")
    }

    @Test("makeFormatter returns correct type for each format")
    func formatterFactory() {
        #expect(makeFormatter(for: .txt) is PlainTextFormatter)
        #expect(makeFormatter(for: .md) is MarkdownFormatter)
        #expect(makeFormatter(for: .json) is JSONFormatter)
    }
}
