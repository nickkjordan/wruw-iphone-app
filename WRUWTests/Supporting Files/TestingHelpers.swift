import Foundation
import XCTest
@testable import Alamofire
@testable import WRUWModule

func stubbedResponse(filename: String) -> NSData! {
    @objc class TestClass: NSObject { }

    let bundle = NSBundle(forClass: TestClass.self)
    let path = bundle.pathForResource(filename, ofType: "json")
    
    return NSData(contentsOfURL: NSURL(fileURLWithPath: path!))
}

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

class MockManager: NetworkManager {
    var expectedRequest: MockRequest?

    func networkRequest(URLRequest: URLRequestConvertible) -> NetworkRequest {
        guard let request = expectedRequest else {
            fatalError("Request is empty.")
        }

        return request
    }
}

class MockRequest {
    var expectedData: NSData? = nil
    var expectedError: NSError? = nil
}

extension MockRequest: NetworkRequest {
    func responseJSON(
        queue queue: dispatch_queue_t?,
        options: NSJSONReadingOptions,
        completionHandler: Response<AnyObject, NSError> -> Void
    ) -> Self {
        let result = Request
            .JSONResponseSerializer(options: options)
            .serializeResponse(nil, nil, expectedData, expectedError)

        if let object = result.value {
            let result: Result<AnyObject, NSError> = .Success(object)
            let response = Response(request: nil, response: nil, data: nil, result: result)
            completionHandler(response)
        } else if let error = result.error {
            let result: Result<AnyObject, NSError> = .Failure(error)
            let response = Response(request: nil, response: nil, data: nil, result: result)
            completionHandler(response)
        } else {
            fatalError("Both data and error are empty.")
        }

        return self
    }
}
