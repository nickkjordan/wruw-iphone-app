import UIKit

typealias TableViewCellConfigure<S: UITableViewCell, T: AnyObject> =
    (S, T) -> Void
