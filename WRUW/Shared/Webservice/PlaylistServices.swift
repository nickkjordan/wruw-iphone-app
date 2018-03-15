import Alamofire
import Foundation

@objc class GetPlaylist: NSObject, WruwAPIClient {
    typealias CompletionResult = Playlist

    var router: NSUrlRequestConvertible {
        return WruwApiRouter(path: "/getplaylist.php", parameters: parameters)
    }

    private let parameters: NSDictionary
    private let manager: NetworkManager

    convenience init(showName: String, date: String) {
        self.init(
            manager: Manager.sharedInstance, showName: showName, date: date)
    }

    init(manager: NetworkManager, showName: String, date: String) {
        self.parameters = ["showname": showName, "date": date]
        self.manager = manager
    }

    @objc func request(completion: (WruwResult) -> Void) {
        manager
            .networkRequest(router as! URLRequestConvertible)
            .json { completion(self.process($0)) }
    }

    func processResultFrom(json: AnyObject) -> WruwResult {
        return processElement(json)
    }
}

@objc class GetPlaylists: NSObject, WruwAPIClient {
    typealias CompletionResult = [PlaylistInfo]

    private let parameters: NSDictionary
    private let manager: NetworkManager

    var router: NSUrlRequestConvertible {
        return WruwApiRouter(path: "/getshow.php", parameters: parameters)
    }

    init(manager: NetworkManager, showName: String) {
        self.parameters = ["showname": showName]
        self.manager = manager
    }
    
    convenience init(showName: String) {
        self.init(manager: Manager.sharedInstance, showName: showName)
    }

    @objc func request(completion: (WruwResult) -> Void) {
        manager
            .networkRequest(router as! URLRequestConvertible)
            .json { completion(self.process($0)) }
    }

    func processResultFrom(json: AnyObject) -> WruwResult {
        guard let json = json as? JSONDict,
            let playlists = json["playlists"] else {
            return WruwResult(failure: processingError)
        }

        return processArray(playlists)
    }
}
