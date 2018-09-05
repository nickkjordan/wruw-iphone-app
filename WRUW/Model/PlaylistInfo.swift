import Foundation

@objc class PlaylistInfo: NSObject, Decodable {
    @objc var identifier: Int = 0,
        date: Date = Date(),
        showName: String = ""

    enum CodingKeys: String, CodingKey {
        case identifier = "PlaylistID"
        case showName = "ShowName"
        case date = "PlaylistDate"
    }

    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy-MM-dd"

        return formatter
    }()

    @objc var dateString: String {
        return PlaylistInfo.dateFormatter.string(from: self.date)
    }
}
