import XCTest
@testable import WRUWModule

class GetPlaylistTests: NetworkingTests {
    fileprivate var playlistService: GetPlaylist!

    override func setUp() {
        super.setUp()

        playlistService =
            GetPlaylist(manager: mockManager, showName: "", date: "")
    }

    // MARK: - Enabled Tests
    func testSuccessResponse() {
        mockManager.expectedRequest?.expectedData = stubbedResponse("Archive")

        playlistService.request { response in
            XCTAssertNotNil(response.success)

            guard let playlist = response.success as? Playlist else {
                XCTFail("Failed to process current show json")
                return
            }

            XCTAssertEqual(playlist.songs?.count, 27)
            self.requestExpectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}

class GetPlaylistsTests: NetworkingTests {
    fileprivate var playlistsService: GetPlaylists!

    override func setUp() {
        super.setUp()

        playlistsService = GetPlaylists(manager: mockManager, showName: "")
    }

    // MARK: - Enabled Tests
    func testSuccessResponse() {
        mockManager.expectedRequest?.expectedData = stubbedResponse("Show")

        playlistsService.request { response in
            XCTAssertNotNil(response.success)

            guard let playlists = response.success as? [PlaylistInfo] else {
                XCTFail("Failed to process current show json")
                return
            }

            XCTAssertEqual(playlists.count, 17)
            self.requestExpectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}
