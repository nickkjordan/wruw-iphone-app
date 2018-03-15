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

    fileprivate let parameters: NSDictionary?
    fileprivate let manager: NetworkManager

    convenience init(release: String, artist: String) {
        self.init(
            manager: Manager.sharedInstance,
            release: release,
            artist: artist
        )
    }

    init(manager: NetworkManager, release: String, artist: String) {
        self.manager = manager
        
        let components = release.components(separatedBy: "-")
        let query = "release:\(components[0]) AND artist:\(artist)"

        parameters = [
            "query": query,
            "fmt": "json"
        ]
    }

    func request(_ completion: @escaping (WruwResult) -> Void) {
        manager
            .networkRequest (router as! URLRequestConvertible)
            .json { completion(self.process($0)) }
    }

    func processResultFrom(_ json: AnyObject) -> WruwResult {
        guard let json = json as? JSONDict,
            let releases = json["releases"] else {
            return WruwResult(failure: processingError)
        }

        return processArray(releases)
    }
}
