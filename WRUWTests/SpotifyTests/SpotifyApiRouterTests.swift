import XCTest
@testable import WRUWModule

class SpotifyApiRouterTests: XCTestCase {
    var router: SpotifyApiRouter!
    var validToken: SpotifyTokenAdapter!
    var invalidToken: SpotifyTokenAdapter!

    override func setUp() {
        super.setUp()

        validToken = SpotifyTokenAdapter(accessToken: "token", expiresIn: 3600)
        invalidToken = SpotifyTokenAdapter(accessToken: "invalid", expiresIn: 0)
    }

    func testValidToken() {
        router = SpotifyApiRouter(path: "", parameters: nil)
        SpotifyApiRouter.token = validToken

        XCTAssertTrue(SpotifyApiRouter.token!.isValid)

        do {
            _ = try router.asURLRequest()
        } catch {
            XCTFail("Token creation invalid")
        }
    }

    func testInvalidToken() {
        router = SpotifyApiRouter(path: "", parameters: nil)
        SpotifyApiRouter.token = invalidToken

        XCTAssertFalse(SpotifyApiRouter.token!.isValid)

        do {
            _ = try router.asURLRequest()
        } catch let error as SpotifyApiError {
            XCTAssertTrue(error == .expiredToken)
        } catch {
            XCTFail("Incorrect error thrown")
        }
    }

    func testPathSetup() {
        router = SpotifyApiRouter(path: "search", parameters: nil)
        SpotifyApiRouter.token = validToken

        guard let request = try? router.asURLRequest() else {
            XCTFail("Invalid request")
            return
        }

        XCTAssertEqual(request.url!.lastPathComponent, "search")

        let absoluteString = "https://api.spotify.com/v1/search"
        XCTAssertEqual(request.url!.absoluteString, absoluteString)
    }
}
