import Foundation
import XCTest
import Alamofire
@testable import WRUWModule

class SpotifyTokenAdapterTests: XCTestCase {
    var adapter: SpotifyTokenAdapter!
    var urlRequest: URLRequest!
    var manager: SessionManager!
    var request: DataRequest!

    var response: DataResponse<Any>!

    override func setUp() {
        super.setUp()

        adapter = SpotifyTokenAdapter(accessToken: "", expiresIn: 60)
        urlRequest =
            try! URLRequest(url: "https://httpbin.org/get", method: .get)
    }

    func testValidToken() {
        XCTAssertTrue(adapter.isValid)
    }

    func testAdaptsAuthorizationHeader() {
        let adaptedRequest = try! adapter.adapt(urlRequest)

        let headerFields = adaptedRequest.allHTTPHeaderFields
        let hasAuthorizationHeader =
            headerFields?.keys.contains("Authorization")

        XCTAssertNotNil(hasAuthorizationHeader)
        XCTAssertTrue(hasAuthorizationHeader!)
    }

    func testThrowsExpiredToken() {
        adapter = SpotifyTokenAdapter(accessToken: "", expiresIn: 0)

        do {
            let _ = try adapter.adapt(urlRequest)
        } catch let error as SpotifyApiError {
            XCTAssertEqual(error, SpotifyApiError.expiredToken)
        } catch {
            XCTFail()
        }
    }
}
