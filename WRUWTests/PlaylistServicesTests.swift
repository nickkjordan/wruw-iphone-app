import XCTest
@testable import WRUWModule

class PlaylistServicesTests: XCTestCase {
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

class GetPlaylistTests: PlaylistServicesTests {
    private var playlistService: GetPlaylist!

    override func setUp() {
        super.setUp()

        playlistService =
            GetPlaylist(manager: mockManager, showName: "", date: "")
    }

    // MARK: - Enabled Tests
    func testSuccessResponse() {
        mockManager.expectedRequest?.expectedData = stubbedResponse("Archive")

        let requestExpectation = expectationWithDescription("request completed")

        playlistService.request { response in
            XCTAssertNotNil(response.success)

            guard let playlist = response.success as? Playlist else {
                XCTFail("Failed to process current show json")
                return
            }

            XCTAssertEqual(playlist.songs.count, 30)
            requestExpectation.fulfill()
        }

        waitForExpectationsWithTimeout(1) { _ in }
    }
}

class GetPlaylistsTests: PlaylistServicesTests {
    private var playlistsService: GetPlaylists!

    override func setUp() {
        super.setUp()

        playlistsService = GetPlaylists(manager: mockManager, showName: "")
    }

    // MARK: - Enabled Tests
    func testSuccessResponse() {
        mockManager.expectedRequest?.expectedData = stubbedResponse("Show")

        let requestExpectation = expectationWithDescription("completed request")

        playlistsService.request { response in
            XCTAssertNotNil(response.success)

            guard let playlists = response.success as? [PlaylistInfo] else {
                XCTFail("Failed to process current show json")
                return
            }

            XCTAssertEqual(playlists.count, 17)
            requestExpectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
