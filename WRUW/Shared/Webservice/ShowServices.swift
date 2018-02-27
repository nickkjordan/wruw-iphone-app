import Alamofire
import Foundation

@objc class CurrentShow: NSObject, WruwAPIClient {
    typealias CompletionResult = Show
    
    var router: WruwAPIRouter {
        return WruwAPIRouter(path: "/currentshow.php")
    }

    @objc func request(completion: (WruwResult) -> Void) {
        Alamofire
            .request(router)
            .responseJSON { completion(self.process($0)) }
    }

    func processResultFrom(json: AnyObject) -> WruwResult {
        return processElement(json)
    }
}

@objc class GetAllShows: NSObject, WruwAPIClient {
    typealias CompletionResult = [Show]

    var router: WruwAPIRouter {
        return WruwAPIRouter(path: "/getfullplaylist.php") 
    }

    @objc func request(completion: (WruwResult) -> Void) {
        Alamofire
            .request(router)
            .responseJSON { completion(self.process($0)) }
    }

    func processResultFrom(json: AnyObject) -> WruwResult {
        return processArray(json)
    }
}
