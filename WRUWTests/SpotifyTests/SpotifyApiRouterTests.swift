import XCTest
@testable import WRUWModule

class SpotifyApiRouterTests: XCTestCase {
    var router: SpotifyApiRouter!
    var validToken: SpotifyToken!
    var invalidToken: SpotifyToken!

    override func setUp() {
        super.setUp()

        validToken = SpotifyToken(accessToken: "token", expiresIn: 3600)
        invalidToken = SpotifyToken(accessToken: "invalid", expiresIn: 0)
    }

    func testValidToken() {
        router = SpotifyApiRouter(path: "", parameters: nil)
        router.token = validToken

        XCTAssertTrue(router.token!.isValid)

        do {
            _ = try router.asURLRequest()
        } catch {
            XCTFail("Token creation invalid")
        }
    }

    func testInvalidToken() {
        router = SpotifyApiRouter(path: "", parameters: nil)
        router.token = invalidToken

        XCTAssertFalse(router.token!.isValid)

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
        router.token = validToken

        let request = try! router.asURLRequest()
        XCTAssertEqual(request.url!.lastPathComponent, "search")

        let absoluteString = "https://api.spotify.com/v1/search"
        XCTAssertEqual(request.url!.absoluteString, absoluteString)
    }
}
