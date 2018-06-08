import Foundation
import Alamofire
import Keys

@objc class SpotifyAuthorizationRouter: NSObject, APIRouter {
    let baseUrlString: String = "https://accounts.spotify.com/api/"

    var method: HTTPMethod = .post
    var path: String

    var parameters: NSDictionary?

    required init(path: String, parameters: NSDictionary?) {
        self.path = path
        self.parameters = parameters
    }
}

extension SpotifyAuthorizationRouter: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let uri = baseUrlString + path

        guard let url = URL(string: uri) else {
            print("failed to construct url from: \(uri)")
            throw ApiError.invalidBaseUrl(string: uri)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
        urlRequest.addValue(
            "Basic \(WRUWKeys().spotifyToken)",
            forHTTPHeaderField: "Authorization"
        )

        let body = "grant_type=client_credentials"
        urlRequest.httpBody =
            body.data(using: .utf8, allowLossyConversion: true)

        return urlRequest
    }
}
