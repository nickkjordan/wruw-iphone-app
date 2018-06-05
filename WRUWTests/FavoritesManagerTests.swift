import XCTest
@testable import WRUWModule

class FavoriteManagerTests: XCTestCase {
    var song: Song!
    var jsonDict: JSONDict!
    let favoritesManager = FavoriteManager(userDefaults: MockUserDefaults())

    func clear() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }

    override func setUp() {
        super.setUp()

        jsonDict = [
            Song.CodingKeys.songName.rawValue: "Atrocity Exhibition",
            Song.CodingKeys.artist.rawValue: "Joy Division",
            Song.CodingKeys.album.rawValue: "Closer",
            Song.CodingKeys.label.rawValue: "London Records"
        ]
        let data = try! JSONEncoder().encode(jsonDict as! [String: String])
        song = try! JSONDecoder().decode(Song.self, from: data)

        clear()
    }

    func testMockCreation() {
        let songName = jsonDict[Song.CodingKeys.songName.rawValue] as? String
        XCTAssertNotNil(songName)

        XCTAssertEqual(song.songName, songName!)
    }

    func testSaveableToUserDefaults() {
        let result = favoritesManager.saveFavorite(song: song)

        XCTAssertTrue(result)
    }

    func testRemovableFavorites() {
        let result = favoritesManager.saveFavorite(song: song)

        XCTAssertTrue(result)

        let removed = favoritesManager.saveFavorite(song: song)

        XCTAssertFalse(removed)
    }
}
