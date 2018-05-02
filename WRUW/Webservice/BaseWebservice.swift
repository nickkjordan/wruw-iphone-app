import Foundation
import Alamofire

@objc protocol APIRouter: NSUrlRequestConvertible {
    var baseUrlString: String { get }

    var path: String { get }

    var parameters: NSDictionary? { get set }

    init(path: String, parameters: NSDictionary?)
}

typealias JSONDict = [AnyHashable: Any]

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
}

class WruwApiClient: NSObject, APIClient {
    internal var manager: NetworkManager

    var router: NSUrlRequestConvertible {
        fatalError()
    }

    convenience init(manager: NetworkManager) {
        self.init()

        self.manager = manager
    }

    // Need separate init, can't have default params used in objc
    override init() {
        manager = SessionManager.default

        super.init()
    }

    func decode(from data: Data) throws -> Any {
        fatalError("Overwrite required")
    }

    @objc func request(completion: @escaping (WruwResult) -> Void) {
        manager
            .networkRequest(router as! URLRequestConvertible)
            .data { completion(self.processData(response: $0)) }
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
            print("decoding error: ",
                  error.errorDescription ?? error.localizedDescription, error)
            return WruwResult(failure: error)
        } catch let error {
            print("other error: ", error.localizedDescription)
            return WruwResult(failure: error)
        }
    }

    var processingError: NSError {
        return
            NSError(domain: "Local Processing Error", code: 400, userInfo: nil)
    }
}
