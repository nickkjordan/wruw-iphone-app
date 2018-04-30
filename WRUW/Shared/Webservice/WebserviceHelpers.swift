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
        // Access JSON object from parent, with potential null values
        let json = try
            JSONSerialization.jsonObject(with: data) as? [String: Any?]

        // Access nested JSON object
        guard case let nestedItem?? = json?[key] else {
            let codingKey = NestedCodingKeys(stringValue: key)!

            throw DecodingError.keyNotFound(codingKey, codingKey.context)
        }

        // Reserialize back to data
        let data = try JSONSerialization.data(withJSONObject: nestedItem)

        return try decode(type, from: data)
    }

    struct NestedCodingKeys: CodingKey {
        var stringValue: String,
            intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            self.init(stringValue: String(intValue))
            self.intValue = intValue
        }

        var context: DecodingError.Context {
            return DecodingError.Context(
                codingPath: [self],
                debugDescription: "nested key \(stringValue) not found"
            )
        }
    }
}
