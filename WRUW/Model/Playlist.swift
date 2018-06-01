import Foundation

@objc class Playlist: NSObject, Decodable {
    var date: String?,
        idValue: Int?,
        songs: [Song]?

    enum CodingKeys: String, CodingKey {
        case songs
        case idValue = "PlaylistID"
        case date = "PlaylistDate"
    }

    func toJSONObject() -> Any {
        return ""
    }
}
