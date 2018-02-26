import Foundation
import Alamofire

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
}
