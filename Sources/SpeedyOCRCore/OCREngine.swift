import CoreGraphics
import Foundation
import Vision

/// Performs OCR on CGImage using the Vision framework.
public struct OCREngine {
    private let languages: [String]
    private let usesLanguageCorrection: Bool

    public init(languages: [String] = ["ja", "en"], usesLanguageCorrection: Bool = true) {
        self.languages = languages
        self.usesLanguageCorrection = usesLanguageCorrection
    }

    /// Recognize text in an image.
    public func recognize(image: CGImage) throws -> String {
        let semaphore = DispatchSemaphore(value: 0)
        var resultText = ""
        var ocrError: Error?

        let request = VNRecognizeTextRequest { request, error in
            defer { semaphore.signal() }

            if let error = error {
                ocrError = error
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            // Sort by Y position (top to bottom: higher Y = higher on page in Vision coordinates)
            let sorted = observations.sorted { $0.boundingBox.origin.y > $1.boundingBox.origin.y }

            let lines = sorted.compactMap { observation -> String? in
                observation.topCandidates(1).first?.string
            }

            resultText = lines.joined(separator: "\n")
        }

        request.recognitionLanguages = languages
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = usesLanguageCorrection

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([request])
        } catch {
            semaphore.signal()
            throw OCREngineError.visionError(error)
        }

        semaphore.wait()

        if let error = ocrError {
            throw OCREngineError.recognitionFailed(error)
        }

        return resultText
    }
}

public enum OCREngineError: LocalizedError {
    case visionError(Error)
    case recognitionFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .visionError(let error):
            return "Vision framework error: \(error.localizedDescription)"
        case .recognitionFailed(let error):
            return "Text recognition failed: \(error.localizedDescription)"
        }
    }
}
