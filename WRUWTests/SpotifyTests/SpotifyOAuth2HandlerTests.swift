import Foundation
import Alamofire
import XCTest
@testable import WRUWModule

class SpotifyOAuth2HandlerTests: XCTestCase {
    var handler: SpotifyOAuth2Handler!
    var manager: SessionManager!

    override func setUp() {
        super.setUp()

        handler = SpotifyOAuth2Handler()

        manager = SessionManager()
        manager.startRequestsImmediately = false
    }

    func testRequestAddedToRetryList() {
        let request = manager.request("https://httpbin.com/get", method: .get)

        handler.should(
            manager,
            retry: request,
            with: SpotifyApiError.expiredToken,
            completion: { _, _ in }
        )

        XCTAssertFalse(handler.requestsToRetry.isEmpty)
    }
}
