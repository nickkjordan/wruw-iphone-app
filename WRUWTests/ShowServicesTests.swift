import XCTest
@testable import WRUWModule

class CurrentShowTests: NetworkingTests {
    fileprivate var currentShowService: CurrentShow!

    override func setUp() {
        super.setUp()

        currentShowService = CurrentShow(manager: mockManager)
    }

    // MARK: - Enabled Tests
    func testSuccessResponse() {
        mockManager.expectedRequest?.expectedData =
            stubbedResponse("CurrentShow")

        currentShowService.request { response in
            XCTAssertNotNil(response.success)

            guard let currentShow = response.success as? Show else {
                XCTFail("Failed to process current show json")
                return
            }

            XCTAssertEqual(currentShow.title, "Democracy Now")
            self.requestExpectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}

class GetAllShowTests: NetworkingTests {
    fileprivate var getAllShowsService: GetAllShows!

    override func setUp() {
        super.setUp()

        getAllShowsService = GetAllShows(manager: mockManager)
    }
    
    // MARK: - Enabled Tests
    func testSuccessResponse() {
        mockManager.expectedRequest?.expectedData = stubbedResponse("AllShows")

        getAllShowsService.request { response in
            XCTAssertNotNil(response.success)

            guard let shows = response.success as? [Show] else {
                XCTFail("Failed to process current show json")
                return
            }

            XCTAssertEqual(shows.count, 100)
            self.requestExpectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}
