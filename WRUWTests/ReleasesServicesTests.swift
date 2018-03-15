import XCTest
@testable import WRUWModule

class ReleasesServicesTests: NetworkingTests {
    // MARK: - Private Properties
    private var releasesService: GetReleases!

    // MARK: - Override Methods
    override func setUp() {
        super.setUp()

        releasesService =
            GetReleases(manager: mockManager, release: "", artist: "")
    }

    // MARK: - Enabled Tests
    func testSuccessResponse() {
        mockManager.expectedRequest?.expectedData = stubbedResponse("Releases")

        releasesService.request { response in
            XCTAssertNotNil(response.success)

            guard let releases = response.success as? [Release] else {
                XCTFail("Failed to process releases json")
                return
            }

            XCTAssertNotNil(releases)
            XCTAssertEqual(releases.count, 25)
            self.requestExpectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
