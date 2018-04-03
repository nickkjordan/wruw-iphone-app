import Foundation
import XCTest
@testable import WRUWModule

class PlaylistTableViewTests: XCTestCase {
    func testRetainCycleDelegateCheck() {
        weak var weakTableView: PlaylistTableView?

        autoreleasepool {
            var tableView: PlaylistTableView? = PlaylistTableView(frame: .zero)

            let viewController = UITableViewController()
            viewController.view.addSubview(tableView!)
            tableView?.scrollViewDelegate = viewController

            weakTableView = tableView

            tableView = nil
        }

        XCTAssertNil(weakTableView)
    }
}
