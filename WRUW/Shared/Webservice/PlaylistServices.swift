import Alamofire
import Foundation

@objc class GetPlaylist: NSObject, WruwAPIClient {
    typealias CompletionResult = Playlist

    var router: NSUrlRequestConvertible {
        return WruwAPIRouter(path: "/getplaylist.php", parameters: parameters)
    }

    private let parameters: NSDictionary

    init(showName: String, date: String) {
        self.parameters = ["showname": showName, "date": date]
    }

    @objc func request(completion: (WruwResult) -> Void) {
        Alamofire
            .request(router as! URLRequestConvertible)
            .responseJSON { completion(self.process($0)) }
    }

    func processResultFrom(json: AnyObject) -> WruwResult {
        return processElement(json)
    }
}

@objc class GetPlaylists: NSObject, WruwAPIClient {
    typealias CompletionResult = [PlaylistInfo]

    private let parameters: NSDictionary

    var router: NSUrlRequestConvertible {
        return WruwAPIRouter(path: "/getshow.php", parameters: parameters)
    }

    init(showName: String) {
        self.parameters = ["showname": showName]
    }

    @objc func request(completion: (WruwResult) -> Void) {
        Alamofire
            .request(router as! URLRequestConvertible)
            .responseJSON { completion(self.process($0)) }
    }

    func processResultFrom(json: AnyObject) -> WruwResult {
        guard let json = json as? JSONDict,
            let playlists = json["playlists"] else {
            return WruwResult(failure: processingError)
        }

        return processArray(playlists)
    }
}
