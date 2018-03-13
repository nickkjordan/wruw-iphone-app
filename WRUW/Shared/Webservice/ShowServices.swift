import Alamofire
import Foundation

@objc class CurrentShow: NSObject, WruwAPIClient {
    typealias CompletionResult = Show
    
    var router: NSUrlRequestConvertible {
        return WruwApiRouter(path: "/currentshow.php")
    }

    private let manager: Manager

    override convenience init() {
        self.init(manager: Manager.sharedInstance)
    }

    init(manager: Manager) {
        self.manager = manager

        super.init()
    }

    @objc func request(completion: (WruwResult) -> Void) {
        manager
            .request(router as! URLRequestConvertible)
            .responseJSON { completion(self.process($0)) }
    }

    func processResultFrom(json: AnyObject) -> WruwResult {
        return processElement(json)
    }
}

@objc class GetAllShows: NSObject, WruwAPIClient {
    typealias CompletionResult = [Show]

    var router: NSUrlRequestConvertible {
        return WruwApiRouter(path: "/getfullplaylist.php")
    }

    private let manager: Manager

    override convenience init() {
        self.init(manager: Manager.sharedInstance)
    }

    init(manager: Manager) {
        self.manager = manager

        super.init()
    }

    @objc func request(completion: (WruwResult) -> Void) {
        manager
            .request(router as! URLRequestConvertible)
            .responseJSON { completion(self.process($0)) }
    }

    func processResultFrom(json: AnyObject) -> WruwResult {
        return processArray(json)
    }
}
