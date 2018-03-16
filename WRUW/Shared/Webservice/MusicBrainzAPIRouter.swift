import Foundation
import Alamofire

@objc class MusicBrainzApiRouter: NSObject, APIRouter {
    let baseUrlString: String = "https://musicbrainz.org/ws/2"

    var method: HTTPMethod = .get
    var path: String

    var parameters: NSDictionary?

    required init(path: String, parameters: NSDictionary?) {
        self.path = path
        self.parameters = parameters
    }
}

extension MusicBrainzApiRouter: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        guard let baseUrl = URL(string: baseUrlString) else {
            print("Failed to construct url from base: \(baseUrlString)")
            throw ApiError.invalidBaseUrl(string: baseUrlString)
        }
        
        let url = baseUrl.appendingPathComponent(path) 
        let urlRequest = URLRequest(url: url)
        let encoding = CustomEncoding()
        let parameters = self.parameters as? [String: Any]

        var request = try encoding.encode(urlRequest, with: parameters)

        print("Created url request:\n" +
            "\t\(request.url?.absoluteString ?? "")")

        print("")

        // Set HTTP Method
        request.httpMethod = method.rawValue

        // No Header in WRUW API
        return request
    }
}

private extension MusicBrainzApiRouter {
    struct CustomEncoding: ParameterEncoding {
        fileprivate func encode(
            _ urlRequest: URLRequestConvertible,
            with parameters: Parameters?
        ) throws -> URLRequest {
            var request = try URLEncoding().encode(urlRequest, with: parameters)

            let urlString = request.url?.absoluteString
                .replacingOccurrences(of: "%3A", with: ":")

            request.url = URL(string: urlString!)

            return request
        }
    }
}
