import Foundation
import Alamofire

@objc protocol NSUrlRequestConvertible {
    func asURLRequest() throws -> URLRequest
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
            manager: SessionManager.default,
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

    func request(completion: @escaping (WruwResult) -> Void) {
        manager
            .networkRequest (router as! URLRequestConvertible)
            .json { completion(self.process($0)) }
    }

    func processResultFrom(json: Any) -> WruwResult {
        guard let json = json as? JSONDict,
            let releases = json["releases"] else {
            return WruwResult(failure: processingError)
        }

        return processArray(releases, type: [Release].self)
    }
}
