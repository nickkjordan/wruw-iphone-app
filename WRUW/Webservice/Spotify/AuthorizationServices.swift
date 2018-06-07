import Foundation

@objc class GetToken: WruwApiClient {
    override var router: NSUrlRequestConvertible {
        return SpotifyAuthorizationRouter(path: "token", parameters: nil)
    }
}
