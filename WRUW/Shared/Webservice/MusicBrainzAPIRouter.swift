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

        let urlRequest: NSMutableURLRequest

        let components =
            NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters?.flatMap { (key, value) in
            NSURLQueryItem(name: key as! String, value: value as? String)
        }

        let addedFragmentsUrl = components.flatMap { $0.URL }

        urlRequest = addedFragmentsUrl
            .flatMap(NSMutableURLRequest.init(URL:))
            ?? NSMutableURLRequest()

        print("Created url request:\n" +
            "\t\(addedFragmentsUrl?.absoluteString ?? "")")

        print("")

        // Set HTTP Method
        urlRequest.HTTPMethod = method.rawValue

        // No Header in WRUW API
        return urlRequest
    }
}
