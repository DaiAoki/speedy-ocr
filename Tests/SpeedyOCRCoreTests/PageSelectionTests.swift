import Foundation
import Testing

@testable import SpeedyOCRCore

@Suite("PageSelection Tests")
struct PageSelectionTests {
    @Test("Parse single page")
    func parseSingle() throws {
        let selection = try PageSelection.parse("5")

        #expect(selection == .ranges([.single(5)]))
        #expect(selection.resolve(totalPages: 10) == [5])
    }

    @Test("Parse page range")
    func parseRange() throws {
        let selection = try PageSelection.parse("1-10")

        #expect(selection.resolve(totalPages: 100) == Array(1...10))
    }

    @Test("Parse mixed selection")
    func parseMixed() throws {
        let selection = try PageSelection.parse("1,3,5-7")

        #expect(selection.resolve(totalPages: 10) == [1, 3, 5, 6, 7])
    }

    @Test("Resolve clamps to total pages")
    func resolveClamps() throws {
        let selection = try PageSelection.parse("1-100")

        #expect(selection.resolve(totalPages: 10) == Array(1...10))
    }

    @Test("Resolve all pages")
    func resolveAll() {
        let selection = PageSelection.all

        #expect(selection.resolve(totalPages: 5) == [1, 2, 3, 4, 5])
    }

    @Test("Parse ignores whitespace")
    func parseWhitespace() throws {
        let selection = try PageSelection.parse(" 1 , 3 , 5 - 7 ")

        #expect(selection.resolve(totalPages: 10) == [1, 3, 5, 6, 7])
    }

    @Test("Parse rejects invalid input")
    func parseInvalid() {
        #expect(throws: PageSelectionError.self) {
            try PageSelection.parse("abc")
        }
    }

    @Test("Parse rejects negative page")
    func parseNegative() {
        #expect(throws: PageSelectionError.self) {
            try PageSelection.parse("0")
        }
    }

    @Test("Parse rejects reversed range")
    func parseReversedRange() {
        #expect(throws: PageSelectionError.self) {
            try PageSelection.parse("10-5")
        }
    }

    @Test("Out of range pages are excluded")
    func outOfRange() throws {
        let selection = try PageSelection.parse("50")

        #expect(selection.resolve(totalPages: 10) == [])
    }

    @Test("Duplicate pages are deduplicated")
    func deduplication() throws {
        let selection = try PageSelection.parse("1,1,1-3")

        #expect(selection.resolve(totalPages: 10) == [1, 2, 3])
    }
}
