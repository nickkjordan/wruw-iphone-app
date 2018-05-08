import Foundation

func ==(lhs: Song, rhs: Song) -> Bool {
    return lhs.artist == rhs.artist && lhs.songName == rhs.songName
}

@objc(Song)

class Song: NSObject, NSCoding, JSONConvertible {
    var artist: String,
        songName: String,
        album: String,
        label: String

    fileprivate var _image: UIImage?

    var image: UIImage {
        get { return _image ?? Song.defaultAlbumArt }
        set { _image = newValue }
    }

    static var defaultAlbumArt: UIImage = {
        let path = Bundle.main.path(forResource: "iTunesArtwork", ofType: "png")

        return UIImage(contentsOfFile: path!)!
    }()

    var noImage: Bool {
        return _image == nil
    }

    required init?(coder aDecoder: NSCoder) {
        self.songName = aDecoder.decodeObject(forKey: "songName") as! String
        self.artist = aDecoder.decodeObject(forKey: "artist") as! String
        self.album = aDecoder.decodeObject(forKey: "album") as! String
        self.label = aDecoder.decodeObject(forKey: "label") as! String
        self._image = aDecoder.decodeObject(forKey: "image") as? UIImage

        super.init()
    }

    enum CodingKeys: String, CodingKey {
        case songName = "SongName"
        case artist = "ArtistName"
        case album = "DiskName"
        case label = "LabelName"
        case loadedImage
    }

    required init(json dict: JSONDict) {
        self.songName = dict[CodingKeys.songName.rawValue] as? String ?? ""
        self.artist = dict[CodingKeys.artist.rawValue] as? String ?? ""
        self.album = dict[CodingKeys.album.rawValue] as? String ?? ""
        self.label = dict[CodingKeys.label.rawValue] as? String ?? ""
    }

    func toJSONObject() -> Any {
        return [
            CodingKeys.songName.rawValue: songName,
            CodingKeys.artist.rawValue: artist,
            CodingKeys.album.rawValue: album,
            CodingKeys.label.rawValue: label,
            CodingKeys.loadedImage.rawValue: [
                "image": UIImagePNGRepresentation(image)
            ]
        ]
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(songName, forKey: "songName")
        aCoder.encode(artist, forKey: "artist")
        aCoder.encode(album, forKey: "album")
        aCoder.encode(label, forKey: "label")
        aCoder.encode(_image, forKey: "image")
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
