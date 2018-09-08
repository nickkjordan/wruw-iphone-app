import UIKit

class PlayStopIconView: UIView {
    let shapeLayer = CAShapeLayer()
    let maskLayer = CAShapeLayer()
    var initialPath = UIBezierPath()
    var fillColor: UIColor!

    init(fillColor: UIColor) {
        super.init(frame: .zero)

        self.fillColor = fillColor
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        // initial shape of the view
        initialPath = RoundedBezierIcons.RoundedPlayIcon(frame: frame)

        // Create initial shape of the view
        shapeLayer.path = initialPath.cgPath
        shapeLayer.fillColor = fillColor.cgColor
        layer.addSublayer(shapeLayer)

        //mask layer
        maskLayer.path = shapeLayer.path
        maskLayer.position =  shapeLayer.position
        layer.mask = maskLayer

        super.layoutSubviews()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        backgroundColor = .clear
    }

    func showPlayIcon(_ show: Bool) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 1

        // Your new shape here
        animation.toValue = show ?
            RoundedBezierIcons.RoundedPlayIcon(frame: frame).cgPath :
            RoundedBezierIcons.RoundedSquareIcon(frame: frame).cgPath

        animation.timingFunction =
            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

        // The next two line preserves the final shape of animation,
        // if you remove it the shape will return to the original shape after the animation finished
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false

        shapeLayer.add(animation, forKey: nil)
        maskLayer.add(animation, forKey: nil)
    }
}
