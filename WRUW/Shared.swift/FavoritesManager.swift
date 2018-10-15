import Foundation

@objc class FavoriteManager: NSObject {
    @objc static let instance: FavoriteManager = {
        return FavoriteManager()
    }()

    fileprivate var userDefaults: UserDefaultsProtocol

    override init() {
        userDefaults = UserDefaults.standard

        super.init()
    }

    convenience init(userDefaults: UserDefaultsProtocol) {
        self.init()

        self.userDefaults = userDefaults
    }

    enum FavoriteKey: String {
        case songs = "favoriteSongs"
        case shows = "favoriteShows"
    }

    // Can't use generics b/c of objc compatibility

    @objc func saveFavorite(show: Show) -> Bool {
        return saveFavorite(item: show, key: .shows)
    }

    @objc func saveFavorite(song: Song) -> Bool {
        return saveFavorite(item: song, key: .songs)
    }

    func saveFavorite<T: Codable & Hashable>(item: T, key: FavoriteKey) -> Bool {
        var favoritesArray: [T] = loadFavorites(with: key)
        var added: Bool

        if let index = favoritesArray.index(of: item) {
            favoritesArray.remove(at: index)
            added = false
        } else {
            favoritesArray.insert(item, at: 0)
            added = true
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(favoritesArray) {
            userDefaults.set(encoded, forKey: key.rawValue)
            return added
        }

        return false
    }

    @objc func loadFavoriteSongs() -> [Song] {
        return loadFavorites(with: .songs)
    }

    @objc func loadFavoriteShows() -> [Show] {
        return loadFavorites(with: .shows)
    }

    func loadFavorites<T: Codable>(with key: FavoriteKey) -> [T] {
        let decoder = JSONDecoder()

        if let data = userDefaults.value(forKey: key.rawValue) as? Data,
            let values = try? decoder.decode([T].self, from: data) {
            return values
        }

        return []
    }
}
