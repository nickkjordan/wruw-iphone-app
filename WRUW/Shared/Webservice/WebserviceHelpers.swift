import Foundation
import Alamofire

extension NSString {
    var asQuery: NSString {
        let nonLetterSet = NSCharacterSet.punctuationCharacterSet()

        let base = lowercaseString
            .componentsSeparatedByCharactersInSet(nonLetterSet)
            .joinWithSeparator("")

        return base.stringByReplacingOccurrencesOfString(" ", withString: "-")
    }
}

protocol NetworkManager {
    func networkRequest(URLRequest: URLRequestConvertible) -> NetworkRequest
}

extension Manager: NetworkManager {
    func networkRequest(URLRequest: URLRequestConvertible) -> NetworkRequest {
        return request(URLRequest) as NetworkRequest
    }
}

public protocol NetworkRequest {
    func responseJSON(
        queue queue: dispatch_queue_t?,
        options: NSJSONReadingOptions,
        completionHandler: Response<AnyObject, NSError> -> Void
    ) -> Self
}

extension NetworkRequest {
    func json(
        queue queue: dispatch_queue_t? = nil,
        options: NSJSONReadingOptions = .AllowFragments,
        completionHandler: Response<AnyObject, NSError> -> Void
    ) -> Self {
        return responseJSON(
            queue: queue,
            options: options,
            completionHandler: completionHandler
        )
    }
}

extension Request: NetworkRequest { }
