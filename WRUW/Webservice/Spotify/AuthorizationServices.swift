import Foundation

@objc class GetToken: WruwApiClient {
    override var router: NSUrlRequestConvertible {
        return SpotifyAuthorizationRouter(path: "token", parameters: nil)
    }

    override func decode(from data: Data) throws -> Any {
        return try decoder.decode(SpotifyToken.self, from: data)
    }
}
