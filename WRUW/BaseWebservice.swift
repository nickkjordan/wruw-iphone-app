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
    @objc var success: Any?
    @objc var failure: Error?

    init(success: AnyObject? = nil, failure: Error? = nil) {
        self.success = success
        self.failure = failure
    }

    override var description: String {
        return success.debugDescription + failure.debugDescription
    }
}

enum ApiError: Error {
    case invalidBaseUrl(string: String)
    case urlEncodingError
}

protocol APIClient {
    var router: NSUrlRequestConvertible { get }

    func request(completion: @escaping (WruwResult) -> Void)

    func processResultFrom(json: Any) -> WruwResult
}

class WruwApiClient: NSObject, APIClient {
    internal var manager: NetworkManager = SessionManager.default
    var router: NSUrlRequestConvertible {
        fatalError()
    }

    func process(_ response: DataResponse<Any>) -> WruwResult {
        switch response.result {
        case .success(let JSON):
            return processResultFrom(json: JSON)
        case .failure(let error):
            print("Request failed with error: \(error)")
            return WruwResult(failure: error)
        }
    }

    func decode(from data: Data) throws -> Any {
        fatalError("Overwrite required")
    }

    @objc func request(completion: @escaping (WruwResult) -> Void) {
        manager
            .networkRequest(router as! URLRequestConvertible)
            .data { completion(self.processData(response: $0)) }
    }

    func processResultFrom(json: Any) -> WruwResult {
        return WruwResult(success: nil, failure: nil)
    }

    lazy var decoder = JSONDecoder()
}

extension WruwApiClient {
    func processData(response: DataResponse<Data>) -> WruwResult {
        if let error = response.error {
            return WruwResult(failure: error)
        }

        guard let data = response.value else {
            return WruwResult(failure: processingError)
        }

        do {
            let result = try decode(from: data)
            return WruwResult(success: result as AnyObject)
        } catch let error as DecodingError {
            print(error.errorDescription ?? error.localizedDescription)
            return WruwResult(failure: error)
        } catch let error {
            print(error.localizedDescription)
            return WruwResult(failure: error)
        }
    }

    var processingError: NSError {
        return
            NSError(domain: "Local Processing Error", code: 400, userInfo: nil)
    }
}

extension WruwApiClient {
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
