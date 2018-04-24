import Foundation
import Alamofire

extension NSString {
    @objc var asQuery: NSString {
        let nonLetterSet = CharacterSet.punctuationCharacters

        let base = lowercased
            .components(separatedBy: nonLetterSet)
            .joined(separator: "")
            .singleWhitespace

        return base.replacingOccurrences(of: " ", with: "-") as NSString
    }
}

extension String {
    var singleWhitespace: String {
        return components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

protocol NetworkManager {
    func networkRequest(_ URLRequest: URLRequestConvertible) -> NetworkRequest
}

extension SessionManager: NetworkManager {
    func networkRequest(_ URLRequest: URLRequestConvertible) -> NetworkRequest {
        return request(URLRequest) as NetworkRequest
    }
}

public protocol NetworkRequest {
    func responseJSON(
        queue: DispatchQueue?,
        options: JSONSerialization.ReadingOptions,
        completionHandler: @escaping (DataResponse<Any>) -> Void
    ) -> Self

    func responseData(
        queue: DispatchQueue?,
        completionHandler: @escaping (DataResponse<Data>) -> Void
    ) -> Self
}

extension NetworkRequest {
    @discardableResult func json(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        completionHandler: @escaping (DataResponse<Any>) -> Void
    ) -> Self {
        return responseJSON(
            queue: queue,
            options: options,
            completionHandler: completionHandler
        )
    }

    @discardableResult func data(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Data>) -> Void
    ) -> Self {
        return responseData(queue: queue, completionHandler: completionHandler)
    }
}

extension DataRequest: NetworkRequest { }
