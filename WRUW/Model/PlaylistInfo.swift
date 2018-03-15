import Foundation

@objc class PlaylistInfo: NSObject, JSONConvertible {
    @objc let id: Int,
    date: Date,
    showName: String

    @objc required init(json dict: JSONDict!) {
        let dict = dict as! [String: AnyObject]

        let dateString = dict["PlaylistDate"] as? String ?? ""
        
        self.id = dict["PlaylistID"] as! Int
        self.date =
            PlaylistInfo.dateFormatter.date(from: dateString) ?? Date()
        self.showName = dict["ShowName"] as! String
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
