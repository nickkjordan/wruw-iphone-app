import Foundation
import Alamofire

@objc protocol NSUrlRequestConvertible {
    func asURLRequest() throws -> URLRequest
}

@objc class GetReleases: WruwApiClient {
    override var router: NSUrlRequestConvertible {
        return MusicBrainzApiRouter(
            path: "/release/",
            parameters: parameters
        )
    }

    fileprivate let parameters: NSDictionary?

    convenience init(release: String, artist: String) {
        self.init(
            manager: SessionManager.default,
            release: release,
            artist: artist
        )
    }

    init(manager: NetworkManager, release: String, artist: String) {
        let release = release.removingSymbols

        let artistQuery = artist
            .removingSymbols
            .replacingWhitespace(separator: " OR ")

        let query = "release:\(release) AND artist:\(artistQuery)"

        parameters = [
            "query": query,
            "fmt": "json"
        ]

        super.init()

        self.manager = manager
    }

    override func decode(from data: Data) throws -> Any {
        return try decoder.decode([Release].self, from: data)
    }
}

private extension String {
    var removingSymbols: String {
        let allowedSet = CharacterSet.alphanumerics.union(.whitespaces)

        return components(separatedBy: allowedSet.inverted).joined()
    }

    func replacingWhitespace(separator: String) -> String {
        return components(separatedBy: .whitespaces)
            .joined(separator: separator)
    }
}
