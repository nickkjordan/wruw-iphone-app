import Foundation
import Alamofire

@objc protocol APIRouter: NSUrlRequestConvertible {
    var baseUrlString: String { get }

    var path: String { get }

    var parameters: NSDictionary? { get set }

    init(path: String, parameters: NSDictionary?)
}

typealias JSONDict = [AnyHashable: Any]

@objc protocol JSONConvertible {
    init(json dict: JSONDict)
}

@objc class WruwResult: NSObject {
    var success: AnyObject?
    var failure: Error?

    init(success: AnyObject? = nil, failure: Error? = nil) {
        self.success = success
        self.failure = failure
    }
}

enum ApiError: Error {
    case invalidBaseUrl(string: String)
    case urlEncodingError
}

@objc protocol WruwAPIClient {
    associatedtype CompletionResult

    var router: NSUrlRequestConvertible { get }

    @objc func request(completion: @escaping (WruwResult) -> Void)

    func processResultFrom(json: Any) -> WruwResult
}

//@objc extension WruwAPIClient {
//    @objc func request(completion: @escaping (WruwResult) -> Void) {
//        Alamofire
//            .request(router as! URLRequestConvertible)
//            .json { completion(self.process($0)) }
////            .responseJSON { completion(self.process($0)) }
//    }
//}

extension WruwAPIClient {
    func process(_ response: DataResponse<Any>) -> WruwResult {
        switch response.result {

        case .success(let JSON):
            return processResultFrom(json: JSON)

        case .failure(let error):
            print("Request failed with error: \(error)")

            return WruwResult(failure: error)
        }
    }

    var processingError: NSError {
        return
            NSError(domain: "Local Processing Error", code: 400, userInfo: nil)
    }
}

extension WruwAPIClient {
    func processElement<T>(_ json: Any, type: T.Type)
        -> WruwResult where T: JSONConvertible {
        guard let jsonDict = json as? JSONDict else {
            print("Incorrect processing of json as dictionary",
                  terminator: "\n\n")
            print(json)

            return WruwResult(failure: processingError)
        }

        let result = T(json: jsonDict)

        return WruwResult(success: result)
    }

    func processArray<T>(_ json: Any, type: T.Type)
        -> WruwResult where T: Sequence, T.Iterator.Element: JSONConvertible {
        guard let jsonArray = json as? [JSONDict] else {
            print("Incorrect processing of json as array", terminator: "\n\n")
            print(json)

            return WruwResult(failure: processingError)
        }

        let result = jsonArray.map { T.Iterator.Element(json: $0) }

        return WruwResult(success: result as AnyObject?)
    }
}
