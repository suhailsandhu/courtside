import XCTest
@testable import Courtside

final class ProbeLinkTests: XCTestCase {
    func testTokenRoundTrip() {
        for token in ["ABC12345", "space & query?", "🏀"] {
            XCTAssertEqual(ProbeLink.token(from: ProbeLink.make(token: token)), token)
        }
    }
    func testRejectsUnrelatedAndMalformedLinks() {
        for text in ["https://widget?token=123", "courtside-probe://other?token=123",
                     "courtside-probe://widget", "courtside-probe://widget?token="] {
            XCTAssertNil(ProbeLink.token(from: URL(string: text)!))
        }
        XCTAssertNil(ProbeLink.token(from: ProbeLink.make(token: String(repeating: "x", count: 101))))
    }
}
