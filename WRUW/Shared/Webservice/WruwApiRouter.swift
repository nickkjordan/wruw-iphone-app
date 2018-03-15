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
        guard let baseUrl = URL(string: baseUrlString),
            let url = baseUrl.appendingPathComponent(path) else {
            print("Failed to construct url from base: \(baseUrlString)")
            return NSMutableURLRequest()
        }
        
        let urlRequest: NSMutableURLRequest

        switch method {
        case .GET:
            let request = NSMutableURLRequest(url: url)
            let encoding = Alamofire.ParameterEncoding.URL
            let parameters = self.parameters as? [String: AnyObject]

            (urlRequest, _) = encoding.encode(request, parameters: parameters)

            print("Created url request:\n\t\(urlRequest.URLString)")

        default:
            urlRequest = NSMutableURLRequest(url: url)

            if let parameters = parameters {
                do {
                    urlRequest.httpBody = try JSONSerialization
                        .data(withJSONObject: parameters, options: [])
                    print("HTTP Body: ", urlRequest.httpBody)
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


