import Alamofire
import Foundation

@objc class CurrentShow: NSObject, WruwAPIClient {
    typealias CompletionResult = Show
    
    var router: NSUrlRequestConvertible {
        return WruwApiRouter(path: "/currentshow.php")
    }

    fileprivate let manager: NetworkManager

    override convenience init() {
        self.init(manager: Manager.sharedInstance)
    }

    init(manager: NetworkManager) {
        self.manager = manager

        super.init()
    }

    @objc func request(_ completion: @escaping (WruwResult) -> Void) {
        manager
            .networkRequest(router as! URLRequestConvertible)
            .json { completion(self.process($0)) }
    }

    func processResultFrom(_ json: AnyObject) -> WruwResult {
        return processElement(json)
    }
}

@objc class GetAllShows: NSObject, WruwAPIClient {
    typealias CompletionResult = [Show]

    var router: NSUrlRequestConvertible {
        return WruwApiRouter(path: "/getfullplaylist.php")
    }

    fileprivate let manager: NetworkManager

    override convenience init() {
        self.init(manager: Manager.sharedInstance)
    }

    init(manager: NetworkManager) {
        self.manager = manager

        super.init()
    }

    @objc func request(_ completion: @escaping (WruwResult) -> Void) {
        manager
            .networkRequest(router as! URLRequestConvertible)
            .json { completion(self.process($0)) }
    }

    func processResultFrom(_ json: AnyObject) -> WruwResult {
        return processArray(json)
    }
}
