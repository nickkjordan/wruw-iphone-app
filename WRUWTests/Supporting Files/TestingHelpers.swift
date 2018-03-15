import Foundation
import XCTest
@testable import Alamofire
@testable import WRUWModule

// Access stubbed json responses
func stubbedResponse(filename: String) -> NSData! {
    @objc class TestClass: NSObject { }

    let bundle = NSBundle(forClass: TestClass.self)
    let path = bundle.pathForResource(filename, ofType: "json")
    
    return NSData(contentsOfURL: NSURL(fileURLWithPath: path!))
}

// Parent class to test services
class NetworkingTests: XCTestCase {
    // MARK: - Private Properties
    var mockManager: MockManager!
    var mockRequest: MockRequest!
    var requestExpectation: XCTestExpectation!

    // MARK: - Override Methods
    override func setUp() {
        super.setUp()

        mockManager = MockManager()
        mockManager.expectedRequest = MockRequest()
        requestExpectation = expectationWithDescription("completed request")
    }
}

// MARK: Mock classes

// Mock Alamofire.Manager
class MockManager: NetworkManager {
    var expectedRequest: MockRequest?

    func networkRequest(URLRequest: URLRequestConvertible) -> NetworkRequest {
        guard let request = expectedRequest else {
            fatalError("Request is empty.")
        }

        return request
    }
}

// Mock Alamofire.Request
class MockRequest {
    var expectedData: NSData? = nil
    var expectedError: NSError? = nil
}

extension MockRequest: NetworkRequest {
    // Replicating Request.responseJSON() 
    func responseJSON(
        queue queue: dispatch_queue_t?,
        options: NSJSONReadingOptions,
        completionHandler: Response<AnyObject, NSError> -> Void
    ) -> Self {
        // Process response
        let result = Request
            .JSONResponseSerializer(options: options)
            .serializeResponse(nil, nil, expectedData, expectedError)

        // Handling a Result instance, error or success
        let response = Response(result: result)
        completionHandler(response)

        return self
    }
}

// MARK: Convenience extensions

extension Response {
    init(result: Result<Value, Error>) {
        self.init(request: nil, response: nil, data: nil, result: result)
    }
}
