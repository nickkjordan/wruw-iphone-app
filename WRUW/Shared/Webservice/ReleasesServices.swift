import Foundation
import Alamofire

@objc protocol NSUrlRequestConvertible {
    var URLRequest: NSMutableURLRequest { get }
}

@objc class GetReleases: NSObject, WruwAPIClient {
    typealias CompletionResult = [Release]

    var router: NSUrlRequestConvertible {
        return MusicBrainzApiRouter(
            path: "/release/",
            parameters: parameters
        )
    }

    private let parameters: NSDictionary?

    init(release: String, artist: String) {
        let query = "release:\(release) AND artist:\(artist)"

        parameters = [
            "query": query,
            "fmt": "json"
        ]
    }

    func request(completion: (WruwResult) -> Void) {
        Alamofire
            .request(router as! URLRequestConvertible)
            .responseJSON { completion(self.process($0)) }
    }

    func processResultFrom(json: AnyObject) -> WruwResult {
        guard let json = json as? JSONDict,
            let releases = json["releases"] else {
            return WruwResult(failure: processingError)
        }

        return processArray(releases)
    }
}
