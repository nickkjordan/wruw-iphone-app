import Foundation
import Alamofire

@objc class CoverArtApiRouter: NSObject, APIRouter {
    let baseUrlString: String = "https://coverartarchive.org/"

    var method: HTTPMethod = .get
    var path: String

    var parameters: NSDictionary?

    required init(path: String, parameters: NSDictionary?) {
        self.path = path
        self.parameters = parameters
    }
}

extension CoverArtApiRouter: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        guard let baseUrl = URL(string: baseUrlString) else {
            print("Failed to construct url from base: \(baseUrlString)")
            throw ApiError.invalidBaseUrl(string: baseUrlString)
        }

        let url = baseUrl.appendingPathComponent(path)

        var urlRequest = URLRequest(url: url)

        print("Created url request:\n" + "\t\(url.absoluteString)")

        print("")

        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
}

@objc class GetCoverArt: WruwApiClient {
    override var router: NSUrlRequestConvertible {
        return CoverArtApiRouter(path: path, parameters: nil)
    }

    fileprivate let path: String

    init(releaseId: String) {
        self.path = "release/\(releaseId)/front-500"
    }

    override func request(completion: @escaping (WruwResult) -> Void) {
        let alamofire = SessionManager.default

        alamofire.delegate.taskWillPerformHTTPRedirection = {
            alamofire.delegate.taskWillPerformHTTPRedirection = nil
            return $3
        }

        Alamofire
            .request(router as! URLRequestConvertible)
            .responseData { response in
                let result = response.result

                print("success: ", result.isSuccess)
                if let value = result.value,
                    let string = String(data: value, encoding: String.Encoding.utf8) {
                    print("value: ", string)
                }

                let error = result.error
                let image = UIImage(data: result.value)

                completion(WruwResult(success: image, failure: error))
            }
    }

    override func processResultFrom(json: Any) -> WruwResult {
        print("Unused processing result called")
        return WruwResult(failure: processingError)
    }

    func processImage(_ data: Data?) -> WruwResult {
        return WruwResult(success: UIImage(data: data))
    }
}

private extension UIImage {
    convenience init?(data: Data?) {
        guard let data = data else { return nil }

        self.init(data: data)
    }
}
