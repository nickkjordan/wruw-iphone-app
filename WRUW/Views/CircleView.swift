import UIKit

class CircleView: UIView {
    override func layoutSubviews() {
        layer.cornerRadius = frame.height / 2
    }
}
