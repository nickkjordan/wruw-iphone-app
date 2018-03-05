import Foundation
import Alamofire

@objc class WruwApiRouter: NSObject, APIRouter, URLRequestConvertible {
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
            let request = NSMutableURLRequest(URL: url)
            let encoding = Alamofire.ParameterEncoding.URL
            let parameters = self.parameters as? [String: AnyObject]

            (urlRequest, _) = encoding.encode(request, parameters: parameters)

            print("Created url request:\n\t\(urlRequest.URLString)")

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


