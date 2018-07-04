import Foundation
import Alamofire

struct SpotifyTokenAdapter: Codable {
    let accessToken: String
    let expiresIn: Date

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .none

        return dateFormatter
    }()

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.accessToken =
            try container.decode(String.self, forKey: .accessToken)

        let expiresIn = try container.decode(Double.self, forKey: .expiresIn)

        self.expiresIn = Date(timeIntervalSinceNow: expiresIn)
    }

    init(accessToken: String, expiresIn: Double) {
        self.accessToken = accessToken
        self.expiresIn = Date(timeIntervalSinceNow: expiresIn)
    }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }

    var isValid: Bool {
        return expiresIn > Date()
    }
}

extension SpotifyTokenAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest

        guard isValid else {
            throw SpotifyApiError.expiredToken
        }

        urlRequest.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "Authorization"
        )

        return urlRequest
    }
}
