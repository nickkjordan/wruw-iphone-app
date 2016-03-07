import UIKit

class BezierIconView: UIView {
    let shapeLayer = CAShapeLayer()
    let maskLayer = CAShapeLayer()
    var initialPath = UIBezierPath()
    var fillColor = UIColor()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        backgroundColor = UIColor.clearColor()
        
        // initial shape of the view
        initialPath = RoundedBezierIcons.RoundedPlayIcon(self.frame)
        
        // Create initial shape of the view
        shapeLayer.path = initialPath.CGPath
        shapeLayer.fillColor = fillColor.CGColor
        layer.addSublayer(shapeLayer)
        
        //mask layer
        maskLayer.path = shapeLayer.path
        maskLayer.position =  shapeLayer.position
        layer.mask = maskLayer
    }
    
    func prepareForTransition(transition:Bool){
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 1
        
        // Your new shape here
        animation.toValue = transition ?
            RoundedBezierIcons.RoundedPlayIcon(self.frame).CGPath :
            RoundedBezierIcons.RoundedSquareIcon(self.frame).CGPath

        animation.timingFunction =
            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        // The next two line preserves the final shape of animation,
        // if you remove it the shape will return to the original shape after the animation finished
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        
        shapeLayer.addAnimation(animation, forKey: nil)
        maskLayer.addAnimation(animation, forKey: nil)
    }
}
