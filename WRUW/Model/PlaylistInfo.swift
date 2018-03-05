import Foundation

@objc class PlaylistInfo: NSObject, JSONConvertible {
    @objc let id: Int,
    date: NSDate,
    showName: String

    @objc required init(json dict: JSONDict!) {
        let dict = dict as! [String: AnyObject]

        let dateString = dict["PlaylistDate"] as? String ?? ""
        
        self.id = dict["PlaylistID"] as! Int
        self.date =
            PlaylistInfo.dateFormatter.dateFromString(dateString) ?? NSDate()
        self.showName = dict["ShowName"] as! String
    }

    static var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()

        formatter.dateFormat = "yyyy-MM-dd"

        return formatter
    }()

    @objc var dateString: String {
        return PlaylistInfo.dateFormatter.stringFromDate(self.date)
    }
}