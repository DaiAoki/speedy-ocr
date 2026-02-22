import ArgumentParser
import Foundation
import SpeedyOCRCore

@main
struct SpeedyOCR: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "speedy-ocr",
        abstract: "Fast PDF OCR powered by macOS Vision Framework",
        version: "0.1.0"
    )

    @Argument(help: "Input PDF file path")
    var inputPDF: String

    @Option(name: .shortAndLong, help: "Output file path (default: stdout)")
    var output: String?

    @Option(name: .shortAndLong, help: "Output format: txt, md, json")
    var format: String = "txt"

    @Option(help: "Page range (e.g. 1-10, 5, 1,3,5-7)")
    var pages: String?

    @Option(help: "Rendering DPI")
    var dpi: Int = 150

    @Option(help: "Recognition languages, comma-separated BCP 47")
    var language: String = "ja,en"

    @Flag(help: "Disable language correction")
    var noLanguageCorrection: Bool = false

    @Flag(help: "Suppress progress output")
    var quiet: Bool = false

    func run() throws {
        guard let outputFormat = OutputFormat(rawValue: format) else {
            throw ValidationError("Invalid format '\(format)'. Use: txt, md, json")
        }

        let pageSelection: PageSelection
        if let pagesStr = pages {
            pageSelection = try PageSelection.parse(pagesStr)
        } else {
            pageSelection = .all
        }

        let languages = language.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }

        let configuration = OCRConfiguration(
            inputPath: inputPDF,
            outputPath: output,
            format: outputFormat,
            pages: pageSelection,
            dpi: dpi,
            languages: languages,
            usesLanguageCorrection: !noLanguageCorrection,
            quiet: quiet
        )

        let pipeline = Pipeline()
        let result = try pipeline.run(configuration: configuration)

        let formatter = makeFormatter(for: configuration.format)
        let outputText = formatter.format(result: result)

        if let outputPath = configuration.outputPath {
            try outputText.write(toFile: outputPath, atomically: true, encoding: .utf8)
            if !quiet {
                fputs("Output written to \(outputPath)\n", stderr)
            }
        } else {
            print(outputText)
        }
    }
}
