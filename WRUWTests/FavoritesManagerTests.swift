import XCTest
@testable import WRUWModule

class FavoriteManagerTests: XCTestCase {
    var song: Song!
    var jsonDict: JSONDict!
    var userDefaults: MockUserDefaults!
    var favoritesManager: FavoriteManager!

    override func setUp() {
        super.setUp()

        userDefaults = MockUserDefaults()
        favoritesManager = FavoriteManager(userDefaults: userDefaults)

        jsonDict = [
            Song.CodingKeys.songName.rawValue: "Atrocity Exhibition",
            Song.CodingKeys.artist.rawValue: "Joy Division",
            Song.CodingKeys.album.rawValue: "Closer",
            Song.CodingKeys.label.rawValue: "London Records"
        ]
        let data = try! JSONEncoder().encode(jsonDict as! [String: String])
        song = try! JSONDecoder().decode(Song.self, from: data)
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
