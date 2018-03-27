import Foundation

@objc class Playlist: NSObject, JSONConvertible {
    var date: String?,
        idValue: String?,
        songs: [Song]?

    required init(json dict: JSONDict) {
        let songs = dict["songs"] as? [JSONDict]

        self.songs = songs?.map(Song.init(json: ))
        self.idValue = dict["PlaylistID"] as? String
        self.date = dict["PlaylistDate"] as? String

        super.init()
    }
}
