import XCTest
@testable import WRUWModule

class SpotifySearchServiceTests: NetworkingTests {
    fileprivate var spotifyService: SearchSpotify!

    override func setUp() {
        super.setUp()

        spotifyService = SearchSpotify(manager: mockManager, query: "")
    }
}
