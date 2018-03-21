import Foundation

class PlaylistTableView: UITableView {
    var archive: [Song]!
    var show: String!,
        date: String!,
        arrayDataSource: ArrayDataSource!

    func load(show: String, date: String) {
        self.show = show
        self.date = date

        load { songs in
            self.archive = songs

            DispatchQueue.main.async {
                self.setupTableView()
            }

            self.getReleaseInfo()
        }
    }

    func load(success: @escaping ([Song]) -> Void) {
        let playlistService = GetPlaylist(showName: show, date: date)

        playlistService.request { result in
            guard let playlist = result.success as? Playlist,
                let songs = playlist.songs as? [Song] else {
                return
            }

            success(Array(songs.reversed()))
        }
    }

    func updateCurrentPlaylist() {
        load { songs in
            let songs = songs.filter { !self.archive.contains($0) }

            if songs.isEmpty { return }

            self.archive.insert(contentsOf: songs, at: 0)
            self.reloadData()

            self.getReleaseInfo()
        }
    }

    func getReleaseInfo() {
        for (i, song) in archive.enumerated() {
            let releasesService =
                GetReleases(release: song.album, artist: song.artist)

            releasesService.request { result in
                guard let releases = result.success as? [Release],
                    !releases.isEmpty else {
                    return
                }

                var index = 0

                var completion: ((WruwResult) -> Void)!

                completion = { (result: WruwResult) in
                    guard let image = result.success as? UIImage else {
                        index += 1

                        self.loadCoverArt(
                            for: releases,
                            index: index,
                            completion: completion
                        )

                        return
                    }

                    print("release number: ", index)

                    song.image = image
                    self.reloadCoverArt(at: i)
                }

                self.loadCoverArt(
                    for: releases,
                    index: index,
                    completion: completion
                )
            }
        }
    }

    func loadCoverArt(
        for releases: [Release],
        index: Int,
        completion: @escaping (WruwResult) -> Void
    ) {
        if releases.count > index {
            let release = releases[index]

            guard !release.id.isEmpty else { return }

            loadCoverArt(id: release.id, completion: completion)
        }
    }

    func loadCoverArt(id: String, completion: @escaping (WruwResult) -> Void) {
        GetCoverArt(releaseId: id).request(completion: completion)
    }

    func reloadCoverArt(at row: Int) {
        DispatchQueue.main.async {
            self.beginUpdates()
            let indexPath = IndexPath(row: row, section: 0)

            self.reloadRows(at: [indexPath], with: .none)
            self.endUpdates()
        }
    }

    func setupTableView() {
        let closure: TableViewCellConfigureBlock = { (cell, song) in
            guard let cell = cell as? SongTableViewCell,
                let song = song as? Song? else {
                return
            }

            cell.configure(for: song, controlView: self)
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
}
