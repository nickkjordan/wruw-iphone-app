import UIKit

extension UIColor {
    static func rgb(r: CGFloat, _ g: CGFloat, _ b: CGFloat , _ alpha: CGFloat = 1)
    -> UIColor {
        return UIColor(
            red: r/255,
            green: g/255,
            blue: b/255,
            alpha: alpha
        )
    }
}
