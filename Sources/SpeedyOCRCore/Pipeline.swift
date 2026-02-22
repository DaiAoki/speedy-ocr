import CoreGraphics
import Foundation

/// Orchestrates the OCR pipeline: load PDF, render pages, run OCR, format output.
public struct Pipeline {
    public init() {}

    /// Run the OCR pipeline with the given configuration.
    public func run(configuration: OCRConfiguration) throws -> OCRResult {
        let loader = PDFLoader()
        let document = try loader.load(path: configuration.inputPath)
        let totalPages = document.numberOfPages

        let fileName = (configuration.inputPath as NSString).lastPathComponent
        let pageNumbers = configuration.pages.resolve(totalPages: totalPages)

        guard !pageNumbers.isEmpty else {
            throw PipelineError.noPagesToProcess
        }

        let renderer = PageRenderer(dpi: configuration.dpi)
        let engine = OCREngine(
            languages: configuration.languages,
            usesLanguageCorrection: configuration.usesLanguageCorrection
        )
        let reporter = ProgressReporter(totalPages: pageNumbers.count, quiet: configuration.quiet)

        reporter.log("Processing \(pageNumbers.count) pages from \(fileName) (\(totalPages) total)")

        let startTime = Date()

        // Thread-safe results storage
        let resultsLock = NSLock()
        var results: [PageResult] = []
        results.reserveCapacity(pageNumbers.count)
        var warnings: [String] = []

        // Process pages in parallel
        DispatchQueue.concurrentPerform(iterations: pageNumbers.count) { index in
            let pageNumber = pageNumbers[index]

            guard let pdfPage = document.page(at: pageNumber) else {
                resultsLock.lock()
                warnings.append("Cannot get page \(pageNumber)")
                resultsLock.unlock()
                return
            }

            do {
                let image = try renderer.render(page: pdfPage)
                let text = try engine.recognize(image: image)

                resultsLock.lock()
                results.append(PageResult(pageNumber: pageNumber, text: text))
                resultsLock.unlock()

                reporter.reportPage(pageNumber)
            } catch {
                resultsLock.lock()
                warnings.append("Page \(pageNumber): \(error.localizedDescription)")
                resultsLock.unlock()
            }
        }

        let elapsed = Date().timeIntervalSince(startTime)
        reporter.log(String(format: "Completed in %.1f seconds", elapsed))

        for warning in warnings {
            reporter.log("Warning: \(warning)")
        }

        results.sort { $0.pageNumber < $1.pageNumber }

        return OCRResult(
            sourceFileName: fileName,
            totalPages: totalPages,
            processedPages: results,
            dpi: configuration.dpi,
            languages: configuration.languages,
            elapsedSeconds: elapsed
        )
    }
}

public enum PipelineError: LocalizedError {
    case noPagesToProcess

    public var errorDescription: String? {
        switch self {
        case .noPagesToProcess:
            return "No pages to process (check --pages range)"
        }
    }
}
