import Foundation
import Alamofire

struct SpotifyTokenAdapter: Codable {
    let accessToken: String
    var expiresIn: Date

    private let lock = NSLock()

    init(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.accessToken =
            try container.decode(String.self, forKey: .accessToken)

        let expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        self.expiresIn = Date(timeIntervalSinceNow: TimeInterval(expiresIn))
    }

    init(accessToken: String, expiresIn: Int) {
        self.accessToken = accessToken
        self.expiresIn = Date(timeIntervalSinceNow: TimeInterval(expiresIn))
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
