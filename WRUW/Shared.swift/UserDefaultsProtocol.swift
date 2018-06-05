import Foundation

protocol UserDefaultsProtocol {
    func set(_ value: Any?, forKey defaultName: String)

    func value(forKey key: String) -> Any?
}

extension UserDefaults: UserDefaultsProtocol { }
