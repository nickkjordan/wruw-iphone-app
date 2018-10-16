import ARAnalytics
import UIKit

class GroupedProgramsTableViewController: UITableViewController {
    private lazy var daysOfWeek = ["Any", "Sunday", "Monday", "Tuesday",
                                   "Wednesday", "Thursday", "Friday",
                                   "Saturday"]
    private let cellIdentifier = "Cell"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let showsViewController = segue.destination as? ShowsTableViewController,
            let day = tableView.indexPathForSelectedRow?.row {

            showsViewController.dayOfWeek = Int32(day)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Programs"
        ARAnalytics.event("Screen view",
                          withProperties: ["screen": "Programs View"])
    }

    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return "Pick A Day"
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ??
            UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)

        cell.accessoryType = .disclosureIndicator

        cell.textLabel?.text = daysOfWeek[indexPath.row]

        return cell
    }
}
