import Foundation
import Alamofire

@objc class CoverArtApiRouter: NSObject, APIRouter {
    let baseUrlString: String = "https://coverartarchive.org/"

    var method: Alamofire.Method = .GET
    var path: String

    var parameters: NSDictionary?

    required init(path: String, parameters: NSDictionary?) {
        self.path = path
        self.parameters = parameters
    }
}

extension CoverArtApiRouter: URLRequestConvertible {
    var URLRequest: NSMutableURLRequest {
        guard let baseUrl = URL(string: baseUrlString),
            let url = baseUrl.appendingPathComponent(path) else {
                print("Failed to construct url from base: \(baseUrlString)")
                return NSMutableURLRequest()
        }

        let urlRequest = NSMutableURLRequest(url: url)

        print("Created url request:\n" +
            "\t\(url.absoluteString ?? "")")

        print("")

        urlRequest.HTTPMethod = method.rawValue

        return urlRequest
    }
}

@objc class GetCoverArt: NSObject, WruwAPIClient {
    typealias CompletionResult = UIImage

    var router: NSUrlRequestConvertible {
        return CoverArtApiRouter(path: path, parameters: nil)
    }

    fileprivate let path: String

    init(releaseId: String) {
        self.path = "release/\(releaseId)/front-500"
    }

    func request(_ completion: @escaping (WruwResult) -> Void) {
        let alamofire = Alamofire.Manager.sharedInstance

        alamofire.delegate.taskWillPerformHTTPRedirection = {
            alamofire.delegate.taskWillPerformHTTPRedirection = nil
            return $0.3
        }

        Alamofire
            .request(router as! URLRequestConvertible)
            .responseData { response in
                let result = response.result

                print("success: ", result.isSuccess)
                if let value = result.value {
                    let string = String(
                        data: value,
                        encoding: NSUTF8StringEncoding
                    )
                    print("value: ", string)
                }

                let error = result.error
                let image = UIImage(data: result.value)
                print(image)

                completion(WruwResult(success: image, failure: error))
            }
    }

    func processResultFrom(_ json: AnyObject) -> WruwResult {
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
