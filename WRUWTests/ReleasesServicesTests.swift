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
//    func testManagerInit() {
//        let manager = releasesService.manager
//
//        XCTAssert(manager, mockManager)
//    }

    func testSuccessResponse() {
        mockManager.expectedRequest?.expectedData = stubbedResponse("Releases")

        releasesService.request { response in
            XCTAssertNotNil(response.success)

            guard let releases = response.success as? [Release] else {
                XCTFail("Failed to process releases json")
                return
            }

            XCTAssertEqual(releases.count, 10)
        }
    }
}
