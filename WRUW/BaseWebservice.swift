import Foundation
import Alamofire

@objc protocol APIRouter: NSUrlRequestConvertible {
    var baseUrlString: String { get }

//    var method: String { get }
    var path: String { get }

    var parameters: NSDictionary? { get set }

    init(path: String, parameters: NSDictionary?)
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

    var router: NSUrlRequestConvertible { get }

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
