import XCTest
@testable import WRUWModule

class WRUWTests: XCTestCase {
    func testBasicQueryCreation() {
        let showName: NSString = "Emergency Donuts"

        let query = showName.asQuery

        XCTAssertEqual(query, "emergency-donuts")
    }

    func testInvalidCharacterQuery() {
        let showName: NSString = "The '59 Sound"

        let query = showName.asQuery

        XCTAssertEqual(query, "the-59-sound")
    }
}
