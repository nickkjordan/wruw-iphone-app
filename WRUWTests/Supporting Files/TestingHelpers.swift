import Foundation
import XCTest
@testable import Alamofire
@testable import WRUWModule

// Access stubbed json responses
func stubbedResponse(_ filename: String) -> Data! {
    @objc class TestClass: NSObject { }

    let bundle = Bundle(for: TestClass.self)
    let path = bundle.path(forResource: filename, ofType: "json")

    return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
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
        requestExpectation = expectation(description: "completed request")
    }
}

// MARK: Mock classes

// Mock Alamofire.Manager
class MockManager: NetworkManager {
    var expectedRequest: MockRequest?

    func networkRequest(_ URLRequest: URLRequestConvertible) -> NetworkRequest {
        guard let request = expectedRequest else {
            fatalError("Request is empty.")
        }

        return request
    }
}

// Mock Alamofire.Request
class MockRequest {
    var expectedData: Data?
    var expectedError: NSError? 
}

extension MockRequest: NetworkRequest {
    func responseData(
        queue: DispatchQueue?,
        completionHandler: @escaping (DataResponse<Data>) -> Void
    ) -> Self {
        return response(
            serializer: DataRequest.dataResponseSerializer(),
            completionHandler: completionHandler
        )
    }

    func response<T>(
        serializer: DataResponseSerializer<T>,
        completionHandler: @escaping (DataResponse<T>) -> Void
    ) -> Self {
        // Process response
        let result =
            serializer.serializeResponse(nil, nil, expectedData, expectedError)

        // Handling a Result instance, error or success
        let response = DataResponse(
            request: nil,
            response: nil,
            data: nil,
            result: result
        )
        completionHandler(response)

        return self
    }
}

// MARK: Convenience extensions

extension DataResponse {
    init(result: Result<Value>) {
        self.init(request: nil, response: nil, data: nil, result: result)
    }
}
