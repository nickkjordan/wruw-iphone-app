import Foundation

struct SpotifyToken: Codable {
    var accessToken: String,
        expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}
