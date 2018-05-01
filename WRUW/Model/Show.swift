import Foundation

@objc class Show: NSObject, Codable {
    @objc var title: String = "",
        url: String = "",
        genre: String = "",
        startTime: Time = Time(),
        endTime: Time = Time(),
        days: [String] = [],
        infoDescription: String = "",
        playlists: [Playlist] = []

    var hosts: [Host] = []

    enum CodingKeys: String, CodingKey {
        case title = "ShowName"
        case url = "ShowUrl"
        case startTime = "OnairTime"
        case endTime = "OffairTime"
        case genre = "ShowCategory"
        case days = "Weekdays"
        case infoDescription = "ShowDescription"
        case hosts = "ShowUsers"
    }

    struct Host: Codable {
        var host: String

        enum CodingKeys: String, CodingKey {
            case host = "DJName"
        }
    }

    @objc override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.url = aDecoder.decodeObject(forKey: "url") as! String
        let hosts = aDecoder.decodeObject(forKey: "hosts") as? [Show.Host]

        if hosts == nil {
            let host = aDecoder.decodeObject(forKey: "host")
            self.hosts = [host] as! [Show.Host]
        } else {
            self.hosts = hosts!
        }

        self.startTime = aDecoder.decodeObject(forKey: "startTime") as! Time
        self.endTime = aDecoder.decodeObject(forKey: "endTime") as! Time
        self.genre = aDecoder.decodeObject(forKey: "genre") as! String

        let days = aDecoder.decodeObject(forKey: "day")

        if days is [String] {
            self.days = days as! [String]
        } else {
            self.days = [days as! String]
        }

        self.infoDescription = aDecoder.decodeObject(forKey: "infoDescription") as! String
    }

    @objc static func formatPath(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter.string(from: date)
    }

    @objc var hostsDisplay: String {
        return hosts.map { $0.host }.joined(separator: ", ")
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let show = object as? Show else {
            return false
        }

        return title == show.title
    }
}
