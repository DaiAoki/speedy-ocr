import Foundation

/// Reports processing progress to stderr.
public final class ProgressReporter {
    private let totalPages: Int
    private let quiet: Bool
    private var processedCount = 0
    private let lock = NSLock()

    public init(totalPages: Int, quiet: Bool) {
        self.totalPages = totalPages
        self.quiet = quiet
    }

    /// Report that a page has been processed.
    public func reportPage(_ pageNumber: Int) {
        guard !quiet else { return }

        lock.lock()
        processedCount += 1
        let count = processedCount
        lock.unlock()

        if count % 25 == 0 || count == totalPages {
            fputs("Progress: \(count)/\(totalPages) pages\n", stderr)
        }
    }

    /// Report a message to stderr.
    public func log(_ message: String) {
        guard !quiet else { return }
        fputs("\(message)\n", stderr)
    }
}
