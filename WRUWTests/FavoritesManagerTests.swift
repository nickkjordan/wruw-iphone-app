import XCTest
@testable import WRUWModule

class FavoriteManagerTests: XCTestCase {
    var song: Song!
    var jsonDict: JSONDict!
    let favoritesManager = FavoriteManager.instance

    override func setUp() {
        super.setUp()

        jsonDict = [
            Song.CodingKeys.songName: "Atrocity Exhibition",
            Song.CodingKeys.artist: "Joy Division",
            Song.CodingKeys.album: "Closer",
            Song.CodingKeys.label: "London Records"
        ]
        song = Song(json: jsonDict)
    }

    func testMockCreation() {
        let songName = jsonDict[Song.CodingKeys.songName] as? String
        XCTAssertNotNil(songName)

        XCTAssertEqual(song.songName, songName!)
    }

    func testSaveableToUserDefaults() {
        let result = favoritesManager.saveFavorite(item: song)

        XCTAssertTrue(result)
    }

    func testRemovableFavorites() {
        let result = favoritesManager.saveFavorite(item: song)

        XCTAssertTrue(result)

        let removed = favoritesManager.saveFavorite(item: song)

        XCTAssertFalse(removed)
    }
}
