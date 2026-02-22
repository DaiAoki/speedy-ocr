import Foundation

/// Configuration for an OCR processing run.
public struct OCRConfiguration {
    public let inputPath: String
    public let outputPath: String?
    public let format: OutputFormat
    public let pages: PageSelection
    public let dpi: Int
    public let languages: [String]
    public let usesLanguageCorrection: Bool
    public let quiet: Bool

    public init(
        inputPath: String,
        outputPath: String? = nil,
        format: OutputFormat = .txt,
        pages: PageSelection = .all,
        dpi: Int = 150,
        languages: [String] = ["ja", "en"],
        usesLanguageCorrection: Bool = true,
        quiet: Bool = false
    ) {
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.format = format
        self.pages = pages
        self.dpi = dpi
        self.languages = languages
        self.usesLanguageCorrection = usesLanguageCorrection
        self.quiet = quiet
    }
}

/// Output format for OCR results.
public enum OutputFormat: String, CaseIterable {
    case txt
    case md
    case json
}

/// Page selection specifier.
public enum PageSelection: Equatable {
    case all
    case ranges([PageRange])

    /// Resolve to concrete page numbers given a total page count.
    public func resolve(totalPages: Int) -> [Int] {
        switch self {
        case .all:
            return Array(1...totalPages)
        case .ranges(let ranges):
            var pages = Set<Int>()
            for range in ranges {
                switch range {
                case .single(let page):
                    if page >= 1 && page <= totalPages {
                        pages.insert(page)
                    }
                case .range(let start, let end):
                    let clamped = max(1, start)...min(end, totalPages)
                    for page in clamped {
                        pages.insert(page)
                    }
                }
            }
            return pages.sorted()
        }
    }

    /// Parse a page range string like "1-10", "5", "1,3,5-7".
    public static func parse(_ string: String) throws -> PageSelection {
        var ranges: [PageRange] = []
        let parts = string.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        for part in parts {
            if part.contains("-") {
                let bounds = part.split(separator: "-", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                guard bounds.count == 2,
                      let start = Int(bounds[0]),
                      let end = Int(bounds[1]),
                      start >= 1,
                      end >= start else {
                    throw PageSelectionError.invalidRange(part)
                }
                ranges.append(.range(start, end))
            } else {
                guard let page = Int(part), page >= 1 else {
                    throw PageSelectionError.invalidPage(part)
                }
                ranges.append(.single(page))
            }
        }

        guard !ranges.isEmpty else {
            throw PageSelectionError.empty
        }

        return .ranges(ranges)
    }
}

/// A single page range element.
public enum PageRange: Equatable {
    case single(Int)
    case range(Int, Int)
}

/// Errors related to page selection parsing.
public enum PageSelectionError: LocalizedError {
    case invalidRange(String)
    case invalidPage(String)
    case empty

    public var errorDescription: String? {
        switch self {
        case .invalidRange(let s):
            return "Invalid page range: '\(s)'"
        case .invalidPage(let s):
            return "Invalid page number: '\(s)'"
        case .empty:
            return "Empty page selection"
        }
    }
}

/// Result of OCR processing for a single page.
public struct PageResult {
    public let pageNumber: Int
    public let text: String

    public init(pageNumber: Int, text: String) {
        self.pageNumber = pageNumber
        self.text = text
    }
}

/// Complete OCR result for a document.
public struct OCRResult {
    public let sourceFileName: String
    public let totalPages: Int
    public let processedPages: [PageResult]
    public let dpi: Int
    public let languages: [String]
    public let elapsedSeconds: Double

    public init(
        sourceFileName: String,
        totalPages: Int,
        processedPages: [PageResult],
        dpi: Int,
        languages: [String],
        elapsedSeconds: Double
    ) {
        self.sourceFileName = sourceFileName
        self.totalPages = totalPages
        self.processedPages = processedPages
        self.dpi = dpi
        self.languages = languages
        self.elapsedSeconds = elapsedSeconds
    }
}
