import Foundation
import Alamofire

@objc class MusicBrainzApiRouter: NSObject, APIRouter {
    let baseUrlString: String = "https://musicbrainz.org/ws/2"

    var method: Alamofire.Method = .GET
    var path: String

    var parameters: NSDictionary?

    required init(path: String, parameters: NSDictionary?) {
        self.path = path
        self.parameters = parameters
    }
}

extension MusicBrainzApiRouter: URLRequestConvertible {
    var URLRequest: NSMutableURLRequest {
        guard let baseUrl = NSURL(string: baseUrlString),
            let url = baseUrl.URLByAppendingPathComponent(path) else {
                print("Failed to construct url from base: \(baseUrlString)")
                return NSMutableURLRequest()
        }

        let urlRequest = NSMutableURLRequest(URL: url)
        let encoding = customEncoding
        let parameters = self.parameters as? [String: AnyObject]

        let (request, _) = encoding.encode(urlRequest, parameters: parameters)

        print("Created url request:\n" +
            "\t\(request.URLString)")

        print("")

        // Set HTTP Method
        request.HTTPMethod = method.rawValue

        // No Header in WRUW API
        return request
    }
}

private extension MusicBrainzApiRouter {
    var customEncoding: ParameterEncoding {
        return ParameterEncoding.Custom { requestConvertible, parameters in
            let (mutableRequest, error) = ParameterEncoding.URL
                .encode(requestConvertible, parameters: parameters)

            let urlString = mutableRequest.URLString
                .stringByReplacingOccurrencesOfString("%3A", withString: ":")

            mutableRequest.URL = NSURL(string: urlString)

            return (mutableRequest, error)
        }
    }
}
