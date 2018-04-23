import Foundation

func ==(lhs: Song, rhs: Song) -> Bool {
    return lhs.artist == rhs.artist && lhs.songName == rhs.songName
}

@objc(Song)

class Song: NSObject, NSCoding, JSONConvertible {
    @objc var artist: String,
        songName: String,
        album: String,
        label: String

    fileprivate var _image: UIImage?

    @objc var image: UIImage {
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

    required init(json dict: JSONDict) {
        self.songName = dict["SongName"] as? String ?? ""
        self.artist = dict["ArtistName"] as? String ?? ""
        self.album = dict["DiskName"] as? String ?? ""
        self.label = dict["LabelName"] as? String ?? ""
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
