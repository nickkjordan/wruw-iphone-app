import UIKit

@objc class Theme: NSObject {
    var streamButtonOrangeColor: UIColor {
        return UIColor.rgb(253, 159, 47)
    }

    var streamButtonRedColor: UIColor {
        return UIColor.rgb(255, 61, 24)
    }

    var wruwMainOrangeColor: UIColor {
        return UIColor.rgb(253, 159, 47)
    }
}

@objc class ThemeManager: NSObject {
    static func current() -> Theme {
        return Theme()
    }
}
