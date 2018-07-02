import Foundation
import Alamofire

struct SpotifyTokenAdapter: Codable {
    let accessToken: String
    let expiresIn: Date

    private let lock = NSLock()

    init(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.accessToken =
            try container.decode(String.self, forKey: .accessToken)

        let expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        print(expiresIn)
        self.expiresIn = Date()
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
        print("\(expiresIn) vs \(Date())")
        return true
    }
}

extension SpotifyTokenAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest

        guard isValid else {
            throw SpotifyApiError.expiredToken
        }

        print("adapting")

        urlRequest.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "Authorization"
        )

        return urlRequest
    }
}
