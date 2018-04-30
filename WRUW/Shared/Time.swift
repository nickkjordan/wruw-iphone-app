import Foundation

@objc class Time: NSObject, Codable {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.defaultDate = Date(timeIntervalSinceReferenceDate: 0)
        return formatter
    }()

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    let date: Date

    enum CodingKeys: String, CodingKey {
        case date
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        self.date = Time.dateFormatter.date(from: string) ?? Date()

        super.init()
    }
    
    @objc init?(string: String) {
        guard let date = Time.dateFormatter.date(from: string) else {
            return nil
        }

        self.date = date
    }

    override init() {
        self.date = Date()

        super.init()
    }

    @objc func displayTime() -> String {
        return Time.displayFormatter.string(from: self.date)
    }
}

func <(lhs: Time, rhs: Time) -> Bool {
    return lhs.date < rhs.date
}

func ==(lhs: Time, rhs: Time) -> Bool {
    return lhs.date == rhs.date
}

extension Time: Comparable  { }
