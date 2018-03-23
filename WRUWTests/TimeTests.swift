import Foundation
import XCTest
@testable import WRUWModule

class TimeTests: XCTestCase {
    var time: Time!

    override func setUp() {
        super.setUp()

        time = Time(string: "00:00:00")
    }

    func testInitSucceeds() {
        XCTAssertNotNil(time)
    }

    func testCreateTimeFromReferenceDate() {
        let referenceDate = NSDate(timeIntervalSinceReferenceDate: 0)

        XCTAssertEqual(referenceDate, time!.date as NSDate)
    }

    func testDisplayTime() {
        XCTAssertEqual("12:00 AM", time.displayTime())
    }

    func testPostMeridiem() {
        let laterTime = Time(string: "14:00:00")
        
        XCTAssertEqual("2:00 PM", laterTime!.displayTime())
    }

    func testComparableTimes() {
        let laterTime = Time(string: "18:00:00")

        XCTAssertTrue(laterTime! > time)
    }
}
