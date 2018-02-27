import Alamofire
import Foundation

@objc class GetPlaylist: NSObject, WruwAPIClient {
    typealias CompletionResult = Playlist

    var router: WruwAPIRouter {
        return WruwAPIRouter(path: "/getplaylist.php", parameters: parameters)
    }

    private let parameters: NSDictionary

    init(showName: String, date: String) {
        let showName = showName
            .lowercaseString
            .stringByReplacingOccurrencesOfString(" ", withString: "-")
        
        self.parameters = ["showname": showName, "date": date]
    }

    @objc func request(completion: (WruwResult) -> Void) {
        Alamofire
            .request(router)
            .responseJSON { completion(self.process($0)) }
    }
}
