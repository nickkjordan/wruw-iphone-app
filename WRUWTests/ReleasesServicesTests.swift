import XCTest
@testable import WRUWModule

class ReleasesServicesTests: XCTestCase {
    // MARK: - Private Properties
    private var mockManager: MockManager!
    private var mockRequest: MockRequest!
    private var releasesService: GetReleases!

    // MARK: - Override Methods
    override func setUp() {
        super.setUp()

        mockManager = MockManager()
        mockManager.expectedRequest = MockRequest()
        releasesService =
            GetReleases(manager: mockManager, release: "", artist: "")
    }

    // MARK: - Enabled Tests
    func testSuccessResponse() {
        mockManager.expectedRequest?.expectedData = stubbedResponse("Releases")

        var releases: [Release]?

        let requestExpectation = expectationWithDescription("request completed")

        releasesService.request { response in
            XCTAssertNotNil(response.success)

            guard let success = response.success as? [Release] else {
                XCTFail("Failed to process releases json")
                return
            }

            releases = success
            requestExpectation.fulfill()
        }

        waitForExpectationsWithTimeout(10) { _ in
            XCTAssertNotNil(releases)
            XCTAssertEqual(releases?.count, 25)
        }
    }
}
