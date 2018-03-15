import Foundation
import Alamofire

extension NSString {
    var asQuery: NSString {
        let nonLetterSet = CharacterSet.punctuationCharacters

        let base = lowercased
            .components(separatedBy: nonLetterSet)
            .joined(separator: "")

        return base.replacingOccurrences(of: " ", with: "-") as NSString
    }
}

protocol NetworkManager {
    func networkRequest(_ URLRequest: URLRequestConvertible) -> NetworkRequest
}

extension Manager: NetworkManager {
    func networkRequest(_ URLRequest: URLRequestConvertible) -> NetworkRequest {
        return request(URLRequest) as NetworkRequest
    }
}

public protocol NetworkRequest {
    func responseJSON(
        queue: DispatchQueue?,
        options: JSONSerialization.ReadingOptions,
        completionHandler: (Response<AnyObject, NSError>) -> Void
    ) -> Self
}

extension NetworkRequest {
    func json(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        completionHandler: (Response<AnyObject, NSError>) -> Void
    ) -> Self {
        return responseJSON(
            queue: queue,
            options: options,
            completionHandler: completionHandler
        )
    }
}

extension Request: NetworkRequest { }
