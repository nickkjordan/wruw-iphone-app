import Foundation
import Alamofire

@objc class WruwApiRouter: NSObject, APIRouter, URLRequestConvertible {
    let baseUrlString = "https://wruwapi.isaac-nicholas.com"

    var method: HTTPMethod = .get
    var path: String

    internal var parameters: NSDictionary?

    required init(
        path: String,
        parameters: NSDictionary? = nil
    ) {
        self.path = path
        self.parameters = parameters
    }

    func asURLRequest() throws -> URLRequest {
        guard let baseUrl = URL(string: baseUrlString) else {
            print("Failed to construct url from base: \(baseUrlString)")
            throw ApiError.invalidBaseUrl(string: baseUrlString)
        }

        let url = baseUrl.appendingPathComponent(path)
        var urlRequest: URLRequest

        switch method {
        case .get:
            let request = URLRequest(url: url)
            let encoding = URLEncoding()
            let parameters = self.parameters as? [String: Any]

            do {
                urlRequest = try encoding.encode(request, with: parameters)
                print("Created url request:\n\t\(urlRequest)")
            } catch {
                throw ApiError.urlEncodingError
            }

        default:
            urlRequest = URLRequest(url: url)

            if let parameters = parameters {
                do {
                    urlRequest.httpBody = try JSONSerialization
                        .data(withJSONObject: parameters, options: [])
                    print("HTTP Body: ", urlRequest.httpBody ?? "Empty")
                } catch {
                    print("Error processing \(path) parameters")
                }
            }
        }

        print("")

        // Set HTTP Method
        urlRequest.httpMethod = method.rawValue

        // No Header in WRUW API
        return urlRequest
    }
}
