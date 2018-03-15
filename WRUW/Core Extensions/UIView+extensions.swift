import UIKit
import SnapKit

extension UIView {
    func onTap(_ target: AnyObject, selector: Selector) -> Self {
        isUserInteractionEnabled = true

        let tapGesture = gestureRecognizers?.first { $0 is UITapGestureRecognizer }

        if let tapGesture = tapGesture {
            tapGesture.addTarget(target, action: selector)
            return self
        }

        addGestureRecognizer(
            UITapGestureRecognizer(target: target, action: selector)
        )
        return self
    }

    func backgroundColor(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }

    func addSubview(_ subview: UIView, constraintMaker: (ConstraintMaker) -> ()) -> Self {
        addSubview(subview)
        subview.snp_makeConstraints(closure: constraintMaker)
        return self
    }
}
