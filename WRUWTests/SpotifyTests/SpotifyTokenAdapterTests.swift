import Foundation
import XCTest
import Alamofire
@testable import WRUWModule

class SpotifyTokenAdapterTests: XCTestCase {
    var adapter: SpotifyTokenAdapter!
    var urlRequest: URLRequest!

    var response: DataResponse<Any>!

    override func setUp() {
        super.setUp()

        adapter = SpotifyTokenAdapter(accessToken: "", expiresIn: 60)
        guard let urlRequest =
            try? URLRequest(url: "https://httpbin.org/get", method: .get) else {
                XCTFail("Invalid request")
                return
        }

        self.urlRequest = urlRequest
    }

    func testValidToken() {
        XCTAssertTrue(adapter.isValid)
    }

    func testAdaptsAuthorizationHeader() {
        guard let adaptedRequest = try? adapter.adapt(urlRequest) else {
            XCTFail("Unable to adapt request")
            return
        }

        let headerFields = adaptedRequest.allHTTPHeaderFields
        let hasAuthorizationHeader =
            headerFields?.keys.contains("Authorization")

        XCTAssertNotNil(hasAuthorizationHeader)
        XCTAssertTrue(hasAuthorizationHeader!)
    }

    func testThrowsExpiredToken() {
        adapter = SpotifyTokenAdapter(accessToken: "", expiresIn: 0)

        do {
            _ = try adapter.adapt(urlRequest)
        } catch let error as SpotifyApiError {
            XCTAssertEqual(error, SpotifyApiError.expiredToken)
        } catch {
            XCTFail("Unexpected Adapter error")
        }
    }
}
