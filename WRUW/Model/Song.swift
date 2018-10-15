import Foundation

func == (lhs: Song, rhs: Song) -> Bool {
    return lhs.artist == rhs.artist && lhs.songName == rhs.songName
}

@objc(Song)

class Song: NSObject, Codable {
    @objc var artist: String,
        songName: String,
        album: String,
        label: String

    fileprivate var loadedImage: ImageWrapper?

    @objc var image: UIImage {
        get { return loadedImage?.image ?? Song.defaultAlbumArt }
        set { loadedImage = ImageWrapper(image: newValue) }
    }

    static var defaultAlbumArt: UIImage = {
        let path = Bundle.main.path(forResource: "iTunesArtwork", ofType: "png")

        return UIImage(contentsOfFile: path!)!
    }()

    var noImage: Bool {
        return loadedImage == nil
    }

    enum CodingKeys: String, CodingKey {
        case songName = "SongName"
        case artist = "ArtistName"
        case album = "DiskName"
        case label = "LabelName"
        case loadedImage
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let song = object as? Song else {
            return false
        }

        return self == song
    }
}

extension Song {
    override var description: String {
        return "Song \"\(songName)\" by \(artist)\n"
    }
}
