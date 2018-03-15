import XCTest
@testable import WRUWModule

class WruwApiRouterTests: XCTestCase {
    let path = "/path"
    let params = NSDictionary(dictionary: ["key": "value"])

    func testPathInit() {
        let router = WruwApiRouter(path: path, parameters: nil)

        XCTAssertEqual(router.path, path)
    }

    func testParametersInit() {
        let router = WruwApiRouter(path: "", parameters: params)

        XCTAssertEqual(router.parameters, params)
    }

    func testUrlRequest() {
        let router = WruwApiRouter(path: path, parameters: params)

        let urlRequest = router.URLRequest

        let url = urlRequest.URL?.absoluteURL

        XCTAssertNotNil(url)

        let fullExpectedUrlString = router.baseUrlString + path + "?key=value"
        let expectedUrl = URL(string: fullExpectedUrlString)

        XCTAssertEqual(url, expectedUrl)
    }

    func testMultipleParamUrlEncoding() {
        let params = NSDictionary(dictionary: ["showname": "emergency-donuts", "date": "2016-02-01"])

        let router = WruwApiRouter(path: path, parameters: params)

        let url = router.URLRequest.URL?.absoluteURL

        let fullExpectedUrlString = router.baseUrlString +
            path +
            "?showname=emergency-donuts&date=2016-02-01"

        let expectedUrl = URL(string: fullExpectedUrlString)

        XCTAssertEqual(url?.path, expectedUrl?.path)
        XCTAssertEqual(url?.host, url?.host)

        XCTAssertEqual((url?.sortedQueries)!, (expectedUrl?.sortedQueries)!)
    }
}

private extension URL {
    var sortedQueries: [String]? {
        return query?.components(separatedBy: "&")
            .sorted()
    }
}
