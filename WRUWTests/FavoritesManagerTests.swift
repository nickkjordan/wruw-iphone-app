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

        guard let stringDict = jsonDict as? [String: String],
            let data = try? JSONEncoder().encode(stringDict),
            let song = try? JSONDecoder().decode(Song.self, from: data) else {
            XCTFail("Failure to construct Song object from json dictionary")
            return
        }

        self.song = song
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
