import Foundation

struct SpotifyToken: Codable {
    let accessToken: String
    var expiresIn: Date

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
