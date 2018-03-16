import Foundation

@objc class Release: NSObject, JSONConvertible {
    let id: String,
        title: String

    @objc required init(json dict: JSONDict) {
        let dict = dict as! [String: AnyObject]

        self.id = dict["id"] as? String ?? ""
        self.title = dict["title"] as? String ?? ""
    }
}
