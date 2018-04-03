import Foundation
import XCTest
@testable import WRUWModule

class PlaylistTableViewTests: XCTestCase {
    func testRetainCycleDelegateCheck() {
        weak var weakTableView: PlaylistTableView?

        autoreleasepool {
            var tableView: PlaylistTableView? = PlaylistTableView(frame: .zero)

            var viewController: UITableViewController? = UITableViewController()
            viewController?.view.addSubview(tableView!)
            _ = viewController?.view
            tableView?.scrollViewDelegate = viewController

            weakTableView = tableView

            viewController = nil
            tableView = nil
        }

        XCTAssertNil(weakTableView)
    }
}
