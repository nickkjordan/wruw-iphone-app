import Alamofire
import Foundation

@objc class GetPlaylist: WruwApiClient {
    override var router: NSUrlRequestConvertible {
        return WruwApiRouter(path: "/getplaylist.php", parameters: parameters)
            as NSUrlRequestConvertible
    }

    fileprivate let parameters: NSDictionary

    convenience init(showName: String, date: String) {
        self.init(
            manager: SessionManager.default, showName: showName, date: date)
    }

    init(manager: NetworkManager, showName: String, date: String) {
        self.parameters = ["showname": showName, "date": date]
        super.init()
        self.manager = manager
    }

    override func decode(from data: Data) throws -> Any {
        return try decoder.decode(Playlist.self, from: data)
    }
}

@objc class GetPlaylists: WruwApiClient {
    fileprivate let parameters: NSDictionary

    override var router: NSUrlRequestConvertible {
        return WruwApiRouter(path: "/getshow.php", parameters: parameters)
    }

    init(manager: NetworkManager, showName: String) {
        self.parameters = ["showname": showName]

        super.init()

        self.manager = manager
        decoder.dateDecodingStrategy = .formatted(PlaylistInfo.dateFormatter)
    }
    
    @objc convenience init(showName: String) {
        self.init(manager: SessionManager.default, showName: showName)
    }

    @objc override func transform(result: Any) -> Any? {
        return (result as? Archives)?.playlists
    }

    override func decode(from data: Data) throws -> Any {
        return try decoder.decode(Archives.self, from: data)
    }
}
