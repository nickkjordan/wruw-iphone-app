import Alamofire
import Foundation

@objc class CurrentShow: WruwApiClient {
    override var router: NSUrlRequestConvertible {
        return WruwApiRouter(path: "/currentshow.php")
    }

    override func decode(from data: Data) throws -> Any {
        return try decoder.decode(Show.self, from: data)
    }
}

@objc class GetAllShows: WruwApiClient {
    override var router: NSUrlRequestConvertible {
        return WruwApiRouter(path: "/getfullplaylist.php")
    }

    override func decode(from data: Data) throws -> Any {
        return try decoder.decode([Show].self, from: data)
    }
}
