import Foundation

struct SpotifyAlbum: Codable {
    var images: [Image]

    struct Image: Codable {
        var height: Int
        var width: Int
        var url: String
    }
}

extension SpotifyAlbum.Image: Comparable { }

func < (lhs: SpotifyAlbum.Image, rhs: SpotifyAlbum.Image) -> Bool {
    return lhs.height < rhs.height
}

func == (lhs: SpotifyAlbum.Image, rhs: SpotifyAlbum.Image) -> Bool {
    return lhs.height == rhs.height && lhs.width == rhs.width
}
