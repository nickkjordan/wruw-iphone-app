import Foundation

class PlaylistTableView: UITableView {
    fileprivate var archive: [Song]!,
        show: String?,
        date: String?,
        arrayDataSource: ArrayDataSource!

    weak var scrollViewDelegate: UIScrollViewDelegate?

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
    var reversed = false

    // MARK: Load archive requests

    // Setup with show name and playlist date, then request playlist
    func load(show: String, date: String) {
        self.show = show
        self.date = date

        load { [unowned self] songs in
            self.archive = songs

            DispatchQueue.main.async {
                self.setupTableView()
            }

            self.getReleaseInfo()
        }
    }

    // Request any new songs in current playlist
    func updateCurrentPlaylist() {
        load { songs in
            var newSongs = songs.filter { !self.archive.contains($0) }

            if newSongs.isEmpty { return }

            let index = self.reversed ? 0 : self.archive.endIndex
            if self.reversed {
                newSongs.reverse()
            }

            self.archive.insert(contentsOf: newSongs, at: index)
            self.reloadData()

            self.getReleaseInfo()
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

    // Get a list of possible releases for each playlist song,
    // then attempt to request cover art
    //
    // If release has no cover art, request is attempted with the next release
    // in order
    func getReleaseInfo() {
        for (i, song) in archive.enumerated() {
            guard song.noImage else {
                return
            }

            let releasesService =
                GetReleases(release: song.album, artist: song.artist)

            releasesService.request { [unowned self] result in
                // Check for correct result
                guard let releases = result.success as? [Release],
                    !releases.isEmpty else {
                    return
                }

                var index = 0

                var completion: ((WruwResult) -> Void)!

                completion = { [weak self] (result: WruwResult) in
                    // Retry with next release in list if no cover art found
                    guard let image = result.success as? UIImage else {
                        index += 1

                        self?.loadCoverArt(
                            for: releases,
                            index: index,
                            completion: completion
                        )

                        return
                    }

                    print("release number: ", index)

                    // Cover art found, load image at cell
                    song.image = image
                    self?.reloadCoverArt(at: i)
                }

                self.loadCoverArt(
                    for: releases,
                    index: index,
                    completion: completion
                )
            }
        }
    }

    // Setup and request cover art for song
    func loadCoverArt(
        for releases: [Release],
        index: Int,
        completion: @escaping (WruwResult) -> Void
    ) {
        guard releases.count > index else {
            print(releases.count, " - ", index)
            return
        }

        let release = releases[index]

        guard !release.id.isEmpty else { return }

        GetCoverArt(releaseId: release.id).request(completion: completion)
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

        let archive = NSMutableArray(array: self.archive)

        let cellIdentifier = "SongTableViewCell"

        arrayDataSource = ArrayDataSource(
            items: archive,
            cellIdentifier: cellIdentifier,
            configureCellBlock: closure
        )
        dataSource = arrayDataSource
        delegate = self

        let nib = UINib(nibName: cellIdentifier, bundle: nil)

        register(nib, forCellReuseIdentifier: cellIdentifier)

        reloadData()
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
