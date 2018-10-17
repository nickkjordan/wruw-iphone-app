import UIKit

class FavoriteShowsViewController: UITableViewController {

    private var favorites = [Show]()

    private lazy var emptyView: UIView = {
        let emptyView = EmptyFavoritesView.emptyShows()

        self.tableView.addSubview(emptyView!) { make in
            make.width.height.equalTo(self.tableView)
            make.top.bottom.left.right.equalTo(self.tableView)
        }
        emptyView?.alpha = 0

        return emptyView!
    }()

    private lazy var configureCell: TableViewCellConfigureBlock = {
        (_ cell, _ item) in
        guard let item = item as? Show, let cell = cell as? ShowCell else { return }

        cell.configure(for: item)
    }

    private lazy var arrayDataSource =
        ArrayDataSource(items: NSMutableArray(array: self.favorites),
                        cellIdentifier: "ShowCell",
                        configureCellBlock: self.configureCell)

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let displayViewController = segue.destination as? DisplayViewController,
            let path = tableView.indexPathForSelectedRow else {
                return
        }

        displayViewController.currentShow = favorites[path.row]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadFavs()

        let nib = UINib(nibName: "ShowCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ShowCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadFavs()
        checkIfEmpty()
    }

    func checkIfEmpty() {
        if favorites.isEmpty {
            UIView.animate(withDuration: 0) {
                self.emptyView.alpha = 1.0
            }

            tableView.separatorStyle = .none
        } else {
            emptyView.removeFromSuperview()

            tableView.separatorStyle = .singleLine
        }
    }

    func loadFavs() {
        favorites = FavoriteManager.instance.loadFavorites(with: .shows)

        setupTableView()
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDisplaySegue", sender: self)
    }

    func setupTableView() {
        tableView.dataSource = arrayDataSource
        tableView.reloadData()
    }
}
