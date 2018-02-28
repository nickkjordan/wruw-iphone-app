import Foundation
import Alamofire

@objc class WruwAPIRouter: NSObject, URLRequestConvertible {
    private let baseUrlString = "https://wruwapi.isaac-nicholas.com"

    private let method: Alamofire.Method
    private let path: String

    private var parameters: NSDictionary?
    
    init(
        path: String,
        method: Alamofire.Method = .GET,
        parameters: NSDictionary? = nil
    ) {
        self.path = path
        self.method = method
        self.parameters = parameters
    }

    var URLRequest: NSMutableURLRequest {
        guard let baseUrl = NSURL(string: baseUrlString),
            let url = baseUrl.URLByAppendingPathComponent(path) else {
            print("Failed to construct url from base: \(baseUrlString)")
            return NSMutableURLRequest()
        }
        
        let urlRequest: NSMutableURLRequest

        switch method {
        case .GET:
            let components =
                NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
            components?.queryItems = parameters?.flatMap { (key, value) in
                NSURLQueryItem(name: key as! String, value: value as? String)
            }

            let addedFragmentsUrl = components.flatMap { $0.URL }

            urlRequest = addedFragmentsUrl
                .flatMap(NSMutableURLRequest.init(URL:))
                    ?? NSMutableURLRequest()
            
            print("Created url request:\n" +
                "\t\(addedFragmentsUrl?.absoluteString ?? "")")

        default:
            urlRequest = NSMutableURLRequest(URL: url)

            if let parameters = parameters {
                do {
                    urlRequest.HTTPBody = try NSJSONSerialization
                        .dataWithJSONObject(parameters, options: [])
                    print("HTTP Body: ", urlRequest.HTTPBody)
                } catch {
                    print("Error processing \(path) parameters")
                }
            }
        }

        print("")

        // Set HTTP Method
        urlRequest.HTTPMethod = method.rawValue

        // No Header in WRUW API
        return urlRequest
    }
}

typealias JSONDict = [NSObject: AnyObject]

@objc protocol JSONConvertible {
    init(json dict: JSONDict!)
}

@objc class WruwResult: NSObject {
    var success: AnyObject?
    var failure: NSError?

    init(success: AnyObject? = nil, failure: NSError? = nil) {
        self.success = success
        self.failure = failure
    }
}

@objc protocol WruwAPIClient {
    associatedtype CompletionResult

    var router: WruwAPIRouter { get }
    
    @objc func request(completion: (WruwResult) -> Void)

    func processResultFrom(json: AnyObject) -> WruwResult
}

extension WruwAPIClient {
    func process(response: Response<AnyObject, NSError>) -> WruwResult {
        switch response.result {

        case .Success(let JSON):
            return processResultFrom(JSON)

        case .Failure(let error):
            print("Request failed with error: \(error)")

            return WruwResult(failure: error)
        }
    }

    var processingError: NSError {
        return
            NSError(domain: "Local Processing Error", code: 400, userInfo: nil)
    }
}

//@objc extension WruwAPIClient {
//    @objc func request(completion: (WruwResult) -> Void) {
//        Alamofire
//            .request(router)
//            .responseJSON { completion(self.process($0)) }
//    }
//}

extension WruwAPIClient where CompletionResult: JSONConvertible {
    func processElement(json: AnyObject) -> WruwResult {
        guard let jsonDict = json as? JSONDict else {
            print("Incorrect processing of json as dictionary",
                  terminator: "\n\n")
            print(json)

            return WruwResult(failure: processingError)
        }

        let result = CompletionResult(json: jsonDict)

        return WruwResult(success: result)
    }
}

typealias JSONArray = SequenceType

extension WruwAPIClient
        where CompletionResult: JSONArray,
        CompletionResult.Generator.Element: JSONConvertible {
    func processArray(json: AnyObject) -> WruwResult {
        guard let jsonArray = json as? [JSONDict] else {
            print("Incorrect processing of json as array", terminator: "\n\n")
            print(json)

            return WruwResult(failure: processingError)
        }

        let result = jsonArray.map { CompletionResult.Generator.Element(json: $0) }

        return WruwResult(success: result)
    }
}
