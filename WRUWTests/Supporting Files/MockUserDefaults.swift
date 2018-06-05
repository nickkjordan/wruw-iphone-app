import Foundation
@testable import WRUWModule

class MockUserDefaults: UserDefaultsProtocol {
    fileprivate var dictionary = [String: Any]()

    func clear() {
        dictionary = [:]
    }

    func set(_ value: Any?, forKey defaultName: String) {
        guard let value = value else { return }

        dictionary[defaultName] = value
    }

    func value(forKey defaultName: String) -> Any? {
        return dictionary[defaultName]
    }
}
