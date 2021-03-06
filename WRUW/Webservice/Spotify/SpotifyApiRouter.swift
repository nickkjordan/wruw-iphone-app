import Foundation
import Alamofire

@objc class SpotifyApiRouter: NSObject, APIRouter {
    let baseUrlString: String = "https://api.spotify.com/v1/"

    var method: HTTPMethod = .get
    var path: String

    var parameters: NSDictionary?

    required init(path: String, parameters: NSDictionary?) {
        self.path = path
        self.parameters = parameters
    }

    static var token: SpotifyTokenAdapter?
}

enum SpotifyApiError: Error {
    case expiredToken
}

extension SpotifyApiRouter: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let uri = baseUrlString + path

        guard let url = URL(string: uri) else {
            print("failed to construct url from: \(uri)")
            throw ApiError.invalidBaseUrl(string: uri)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        let parameters = self.parameters as? [String: Any]

        return try URLEncoding().encode(urlRequest, with: parameters)
    }
}
