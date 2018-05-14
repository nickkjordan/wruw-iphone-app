import Foundation

@objc class FavoriteManager: NSObject {
    @objc static let instance: FavoriteManager = {
        return FavoriteManager()
    }()

    enum FavoriteKey: String {
        case Songs = "favoriteSongs"
        case Shows = "favoriteShows"

        static func key<T>(for type: T) -> FavoriteKey {
            switch type {
            case is Song:
                return .Songs
            default:
                return .Shows
            }
        }
    }

    @discardableResult @objc func saveFavorite(show: Show) -> Bool {
        return saveFavorite(item: show, key: .Shows)
    }

    @discardableResult @objc func saveFavorite(song: Song) -> Bool {
        return saveFavorite(item: song, key: .Songs)
    }

    func saveFavorite<T: JSONConvertible & Hashable>(item: T) -> Bool {
        let key = FavoriteKey.key(for: T.self)

        return saveFavorite(item: item, key: key)
    }

    typealias Cacheable = JSONConvertible & Hashable

    func saveFavorite<T: Cacheable>(item: T, key: FavoriteKey) -> Bool {
        var favoritesArray: [T] = loadFavorites(with: key)
        var added: Bool

        if let index = favoritesArray.index(of: item) {
            favoritesArray.remove(at: index)
            added = false
        } else {
            favoritesArray.insert(item, at: 0)
            added = true
        }

        return storeFavorites(items: favoritesArray, key: key) ?? added
    }

    func saveFavorites<T: Cacheable>(items: [T], key: FavoriteKey) {
        var favoritesSet = Set<T>(loadFavorites(with: key))

        favoritesSet = favoritesSet.union(items)

        _ = storeFavorites(items: Array(favoritesSet), key: key)
    }

    func storeFavorite(songs: [Song]) {
        _ = storeFavorites(items: songs, key: .Songs)
    }

    func storeFavorite(shows: [Show]) {
        _ = storeFavorites(items: shows, key: .Shows)
    }

    func storeFavorites<T: Cacheable>(items: [T], key: FavoriteKey) -> Bool? {
        let jsonObject = items.map { $0.toJSONObject() }

        guard JSONSerialization.isValidJSONObject(jsonObject),
            let data = try? JSONSerialization.data(withJSONObject: jsonObject)
            else {
                return false
        }

        UserDefaults.standard.set(data, forKey: key.rawValue)

        return nil
    }

    @objc func loadFavoriteSongs() -> [Song] {
        return loadFavorites(with: .Songs)
    }

    @objc func loadFavoriteShows() -> [Show] {
        return loadFavorites(with: .Shows)
    }

    func loadFavorites<T: JSONConvertible>(with key: FavoriteKey) -> [T] {
        guard let data = UserDefaults.standard.data(forKey: key.rawValue),
            let values = try? JSONSerialization.jsonObject(with: data),
            let favorites = values as? [JSONDict] else {
                return []
        }

        return favorites.map { T(json: $0) }
    }
}