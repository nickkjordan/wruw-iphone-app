import Foundation

class ArchiveViewController: UIViewController {
    var currentPlaylist: PlaylistInfo!,
        currentShowTitle: String!

    @IBOutlet var tableView: PlaylistTableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = currentPlaylist.dateString

        let showName = (currentPlaylist.showName as NSString).asQuery as String

        tableView.load(show: showName, date: currentPlaylist.dateString)
    }
}
