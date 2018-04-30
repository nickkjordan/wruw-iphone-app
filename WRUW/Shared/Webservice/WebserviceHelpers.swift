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
    func responseData(
        queue: DispatchQueue?,
        completionHandler: @escaping (DataResponse<Data>) -> Void
    ) -> Self
}

extension NetworkRequest {
    @discardableResult func data(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Data>) -> Void
    ) -> Self {
        return responseData(queue: queue, completionHandler: completionHandler)
    }
}

extension DataRequest: NetworkRequest { }

extension JSONDecoder {
    func decode<T>(type: T.Type, nested key: String, from data: Data) throws -> T where T: Decodable {
        let json = try
            JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let nestedItem = json?[key] else {
            let codingKey = CodingKeys.parent
            let context = DecodingError.Context(
                codingPath: [codingKey],
                debugDescription: "nested key \(key) not found"
            )

            throw DecodingError.keyNotFound(codingKey, context)
        }

        let data = try JSONSerialization.data(withJSONObject: nestedItem)

        return try decode(type, from: data)
    }

    enum CodingKeys: String, CodingKey {
        case parent
    }
}
