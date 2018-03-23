import Foundation

class Time {
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
    
    init?(string: String) {
        guard let date = Time.dateFormatter.date(from: string) else {
            return nil
        }

        self.date = date
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var displayTime: String {
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
