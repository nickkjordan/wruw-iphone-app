import XCTest
@testable import WRUWModule

class ShowServicesTests: XCTestCase {
    // MARK: - Private Properties
    private var mockManager: MockManager!
    private var mockRequest: MockRequest!

    // MARK: - Override Methods
    override func setUp() {
        super.setUp()

        mockManager = MockManager()
        mockManager.expectedRequest = MockRequest()
    }
}

class CurrentShowTests: ShowServicesTests {
    private var currentShowService: CurrentShow!

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
        }
    }
}

class GetAllShowTests: ShowServicesTests {
    private var getAllShowsService: GetAllShows!

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
        }
    }
}
