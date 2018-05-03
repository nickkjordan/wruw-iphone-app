import Foundation

@objc class FavoriteManager: NSObject {
    @objc static let instance: FavoriteManager = {
        return FavoriteManager()
    }()

    enum FavoriteKey: String {
        case Songs = "favoriteSongs"
        case Shows = "favoriteShows"
    }

    @objc func saveFavorite(show: Show) -> Bool {
        return saveFavorite(item: show, key: .Shows)
    }

    @objc func saveFavorite(song: Song) -> Bool {
        return saveFavorite(item: song, key: .Songs)
    }

    func saveFavorite<T: JSONConvertible & Hashable>(item: T, key: FavoriteKey) -> Bool {
        var favoritesArray: [T] = loadFavorites(with: key)
        var added: Bool

        if let index = favoritesArray.index(of: item) {
            favoritesArray.remove(at: index)
            added = false
        } else {
            favoritesArray.insert(item, at: 0)
            added = true
        }

        return JSONSerialization.isValidJSONObject(item)
//
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(favoritesArray) {
//            UserDefaults.standard.set(encoded, forKey: key.rawValue)
//            return added
//        }
//
//        return false
    }

    @objc func loadFavoriteSongs() -> [Song] {
        return loadFavorites(with: .Songs)
    }

    @objc func loadFavoriteShows() -> [Show] {
        return loadFavorites(with: .Shows)
    }

    func loadFavorites<T: JSONConvertible>(with key: FavoriteKey) -> [T] {
        if let data = UserDefaults.standard.data(forKey: key.rawValue),
            case let values?? = try? JSONSerialization.jsonObject(with: data) as? Array<JSONDict> {
            return values.flatMap { T(json: $0) }
        }

        return []
    }
}
