import Alamofire
import Foundation

@objc class CurrentShow: WruwApiClient {
    typealias ResultType = Show

    override var router: NSUrlRequestConvertible {
        return WruwApiRouter(path: "/currentshow.php")
    }

    override convenience init() {
        self.init(manager: SessionManager.default)
    }

    init(manager: NetworkManager) {
        super.init()

        self.manager = manager
    }

    @objc override func request(completion: @escaping (WruwResult) -> Void) {
        manager
            .networkRequest(router as! URLRequestConvertible)
            .json { completion(self.process($0)) }
    }

    override func processResultFrom(json: Any) -> WruwResult {
        return processElement(json, type: Show.self)
    }
}

@objc class GetAllShows: WruwApiClient {
    typealias ResultType = [Show]

    override var router: NSUrlRequestConvertible {
        return WruwApiRouter(path: "/getfullplaylist.php")
    }

    override convenience init() {
        self.init(manager: SessionManager.default)
    }

    init(manager: NetworkManager) {
        super.init()

        self.manager = manager
    }

    @objc override func request(completion: @escaping (WruwResult) -> Void) {
        manager
            .networkRequest(router as! URLRequestConvertible)
            .json { completion(self.process($0)) }
    }

    override func processResultFrom(json: Any) -> WruwResult {
        return processArray(json, type: [Show].self)
    }
}
