import Foundation
import Alamofire

@objc class SearchSpotify: WruwApiClient {
    static let spotifyManager: SessionManager = {
        let manager = SessionManager()
        manager.adapter = SpotifyApiRouter.token
        manager.retrier = SpotifyOAuth2Handler()
        return manager
    }()

    override var router: NSUrlRequestConvertible {
        return SpotifyApiRouter(path: "search", parameters: parameters)
    }

    var parameters: NSDictionary

    init(
        manager: NetworkManager = SearchSpotify.spotifyManager,
        query: String,
        type: String = "album"
    ) {
        self.parameters = [
            "query": query,
            "type": type
        ]

        super.init()

        self.manager = manager
    }

    override func decode(from data: Data) throws -> Any {
        return try decoder.decode(
            type: [SpotifyAlbum].self,
            multiple: ["albums", "items"],
            from: data
        )
    }
}
