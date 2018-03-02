import Foundation
import Alamofire

@objc class WruwAPIRouter: NSObject, APIRouter, URLRequestConvertible {
    let baseUrlString = "https://wruwapi.isaac-nicholas.com"

    var method: Alamofire.Method = .GET
    var path: String

    internal var parameters: NSDictionary?
    
    required init(
        path: String,
        parameters: NSDictionary? = nil
    ) {
        self.path = path
        self.parameters = parameters
    }

    var URLRequest: NSMutableURLRequest {
        guard let baseUrl = NSURL(string: baseUrlString),
            let url = baseUrl.URLByAppendingPathComponent(path) else {
            print("Failed to construct url from base: \(baseUrlString)")
            return NSMutableURLRequest()
        }
        
        let urlRequest: NSMutableURLRequest

        switch method {
        case .GET:
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

        default:
            urlRequest = NSMutableURLRequest(URL: url)

            if let parameters = parameters {
                do {
                    urlRequest.HTTPBody = try NSJSONSerialization
                        .dataWithJSONObject(parameters, options: [])
                    print("HTTP Body: ", urlRequest.HTTPBody)
                } catch {
                    print("Error processing \(path) parameters")
                }
            }
        }

        print("")

        // Set HTTP Method
        urlRequest.HTTPMethod = method.rawValue

        // No Header in WRUW API
        return urlRequest
    }
}


