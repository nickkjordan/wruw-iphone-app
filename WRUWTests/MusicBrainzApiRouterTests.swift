import XCTest
@testable import WRUWModule

class MusicBrainzApiRouterTests: XCTestCase {
    let path = "/path"
    let params = NSDictionary(dictionary: ["key": "value"])

    func testPathInit() {
        let router = MusicBrainzApiRouter(path: path, parameters: nil)

        XCTAssertEqual(router.path, path)
    }

    func testParametersInit() {
        let router = MusicBrainzApiRouter(path: "", parameters: params)

        XCTAssertEqual(router.parameters, params)
    }

    func testUrlRequest() {
        let router = MusicBrainzApiRouter(path: path, parameters: params)

        let urlRequest = router.URLRequest

        let url = urlRequest.URL?.absoluteURL

        XCTAssertNotNil(url)

        let fullExpectedUrlString = router.baseUrlString + path + "?key=value"
        let expectedUrl = NSURL(string: fullExpectedUrlString)

        XCTAssertEqual(url, expectedUrl)
    }

    func testCustomUrlEncoding() {
        let params = NSDictionary(dictionary: ["release": "artist:the beatles"])

        let router = MusicBrainzApiRouter(path: path, parameters: params)

        let url = router.URLRequest.URL?.absoluteURL

        let fullExpectedUrlString =
            router.baseUrlString + path + "?release=artist:the%20beatles"

        let expectedUrl = NSURL(string: fullExpectedUrlString)

        XCTAssertEqual(url, expectedUrl)
    }
}
