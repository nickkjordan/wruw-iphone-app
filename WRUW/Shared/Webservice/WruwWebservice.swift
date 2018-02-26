import Foundation
import Alamofire

@objc class WruwAPIRouter: NSObject, URLRequestConvertible {
    private let baseUrlString = "https://wruwapi.isaac-nicholas.com/"

    private let method: Alamofire.Method
    private let path: String
    
    init(path: String, method: Alamofire.Method = .GET) {
        self.path = path
        self.method = method
    }

    var URLRequest: NSMutableURLRequest {
        guard let baseUrl = NSURL(string: baseUrlString),
            let url = baseUrl.URLByAppendingPathComponent(path) else {
            print("Failed to construct url from base: \(baseUrlString)")
            return NSMutableURLRequest()
        }
        
        print("Created url request: \(url.absoluteString ?? "")")
        
        let urlRequest = NSMutableURLRequest(URL: url)
        
        // Set HTTP Method
        urlRequest.HTTPMethod = method.rawValue
        
        // No Header in WRUW API
        return urlRequest
    }
}

@objc protocol JSONConvertible {
    init(json dict: [NSObject: AnyObject]!)
}

@objc class WruwResult: NSObject {
    var success: JSONConvertible?
    var failure: NSError?

    init(success: JSONConvertible? = nil, failure: NSError? = nil) {
        self.success = success
        self.failure = failure
    }
}

@objc protocol WruwAPIClient {
    associatedtype CompletionResult: JSONConvertible

    var router: WruwAPIRouter { get }
    
    @objc func request(completion: (WruwResult) -> Void)
}

//@objc extension WruwAPIClient {
//    @objc func request(completion: (WruwResult) -> Void) {
//        Alamofire
//            .request(router)
//            .responseJSON { completion(self.process($0)) }
//    }
//}

extension WruwAPIClient {
    func process(response: Response<AnyObject, NSError>) -> WruwResult {
        switch response.result {

        case .Success(let JSON):
            let response = JSON as! [NSObject: AnyObject]
            let result = CompletionResult(json: response)

            return WruwResult(success: result)

        case .Failure(let error):
            print("Request failed with error: \(error)")

            return WruwResult(failure: error)
        }
    }
}
