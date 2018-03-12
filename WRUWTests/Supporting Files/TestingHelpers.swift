import Foundation
@testable import Alamofire

func stubbedResponse(filename: String) -> NSData! {
    @objc class TestClass: NSObject { }

    let bundle = NSBundle(forClass: TestClass.self)
    let path = bundle.pathForResource(filename, ofType: "json")
    
    return NSData(contentsOfURL: NSURL(fileURLWithPath: path!))
}

class MockManager: Manager {
    var expectedRequest: MockRequest?

    override func request(URLRequest: URLRequestConvertible) -> Request {
        guard let request = expectedRequest else {
            fatalError("Request is empty.")
        }

        return request
    }
}

class MockRequest: Request {
    var expectedData: NSData?
    var expectedError: NSError?

    init() {
        expectedData = nil
        expectedError = nil

        super.init(session: NSURLSession(), task: NSURLSessionTask())
    }

    func apiResponse(completionHandler: Response<NSData, NSError> -> Void) -> Self {
        if let data = expectedData {
            let result: Result<NSData, NSError> = .Success(data)
            let response = Response(request: nil, response: nil, data: nil, result: result)
            completionHandler(response)
        } else if let error = expectedError {
            let result: Result<NSData, NSError> = .Failure(error)
            let response = Response(request: nil, response: nil, data: nil, result: result)
            completionHandler(response)
        } else {
            fatalError("Both data and error are empty.")
        }

        return self
    }
}
