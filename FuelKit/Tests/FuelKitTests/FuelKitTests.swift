import XCTest
@testable import FuelKit

final class FuelKitPackageTests: XCTestCase {
    func testDateHelpers() {
        let date = Date.now
        XCTAssertTrue(date.isToday)
        XCTAssertFalse(date.daysAgo(1).isToday)
        XCTAssertNotNil(Date.fromKey(date.dateKey))
    }
}
