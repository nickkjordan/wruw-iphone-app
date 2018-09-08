import Foundation
import Alamofire

class PlaylistTableView: UITableView {
    fileprivate var archive: [Song]!,
        show: String?,
        date: String?,
        arrayDataSource: ArrayDataSource!

    @objc weak var scrollViewDelegate: UIScrollViewDelegate?

    lazy var spinnerView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        self.addSubview(view) { make in
            make.center.equalTo(self)
        }
        view.activityIndicatorViewStyle = .gray
        view.color = UIColor.orange
        return view
    }()

    // Configure order of song list
    //
    // true: top is most recent song.
    // false: playlist in order in which songs were played (most recent is last)
    @objc var reversed = false

    // MARK: Load archive requests

    // Setup with show name and playlist date, then request playlist
    @objc func load(show: String, date: String) {
        setupTableView()

        self.show = show
        self.date = date

        load { [unowned self] songs in
            self.arrayDataSource.items = NSMutableArray(array: songs)

            DispatchQueue.main.async {
                self.reloadData()
            }

            self.loadSpotifyArt()
        }
    }

    // Request any new songs in current playlist
    @objc func updateCurrentPlaylist() {
        load { songs in
            var newSongs =
                songs.filter { !self.arrayDataSource.items.contains($0) }

            if newSongs.isEmpty { return }

            let index = self.reversed ? 0 : self.arrayDataSource.items.count - 1
            if self.reversed {
                newSongs.reverse()
            }

            let indexSet = IndexSet(integer: index)
            self.arrayDataSource.items.insert(newSongs, at: indexSet)

            DispatchQueue.main.async {
                self.reloadData()
            }

            self.loadSpotifyArt()
        }
    }
}

fileprivate extension PlaylistTableView {
    // Request the current playlist
    func load(success: @escaping ([Song]) -> Void) {
        guard let show = show, let date = date else {
            return
        }

        let playlistService = GetPlaylist(showName: show, date: date)

        spinnerView.startAnimating()

        playlistService.request { [unowned self] result in
            self.spinnerView.stopAnimating()

            guard let playlist = result.success as? Playlist,
                let songs = playlist.songs else {
                return
            }

            // Set order in ascending or descending based on time played
            let songList = self.reversed ?
                Array(songs.reversed()) :
                songs

            success(songList)
        }
    }

    // MARK: Release and Cover Art Requests

    func loadSpotifyArt() {
        for (index, song) in self.arrayDataSource.items.enumerated() {
            guard let song = song as? Song, song.noImage else {
                return
            }

            let spotifySearch =
                SearchSpotify(query: "\(song.album!) \(song.artist!)")

            spotifySearch.request { [unowned self] result in
                guard let albums = result.success as? [SpotifyAlbum],
                    let albumArt = albums.first?.images.sorted(by: >),
                    let largestAlbumArt = albumArt.first else {
                    return
                }

                SessionManager.default
                    .request(largestAlbumArt.url, method: .get)
                    .validate()
                    .response { [unowned self] response in
                        guard let value = response.data,
                            let image = UIImage(data: value) else {
                            print(response.error ?? "error")
                            return
                        }

                        song.image = image
                        self.reloadCoverArt(at: index)
                }
            }
        }
    }

    // Reload song cell at row
    func reloadCoverArt(at row: Int) {
        DispatchQueue.main.async {
            self.beginUpdates()
            let indexPath = IndexPath(row: row, section: 0)

            self.reloadRows(at: [indexPath], with: .none)
            self.endUpdates()
        }
    }

    // MARK: Config

    // Setup the dataSource with associated cell class
    func setupTableView() {
        let closure: TableViewCellConfigureBlock = { (cell, song) in
            guard let cell = cell as? SongTableViewCell,
                let song = song as? Song? else {
                return
            }

            cell.configure(for: song)
        }

        let cellIdentifier = "SongTableViewCell"

        arrayDataSource = ArrayDataSource(
            items: [],
            cellIdentifier: cellIdentifier,
            configureCellBlock: closure
        )
        dataSource = arrayDataSource
        delegate = self

        let nib = UINib(nibName: cellIdentifier, bundle: nil)

        register(nib, forCellReuseIdentifier: cellIdentifier)
    }
}

extension PlaylistTableView: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        let cell = cellForRow(at: indexPath)

        if (cell?.isSelected)! {
            deselectRow(at: indexPath, animated: true)

            return nil
        }

        return indexPath
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        scrollViewDelegate?
            .scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}
