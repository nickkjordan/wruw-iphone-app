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

    @objc override init() {
        super.init()
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

struct Host: Codable {
    var host: String

    enum CodingKeys: String, CodingKey {
        case host = "DJName"
    }
}
