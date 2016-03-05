import UIKit

protocol Status {
    func statusChange()
}

class AnimatedButton: UIView, UIGestureRecognizerDelegate {
    var delegate:Status?
    
    var status = false // status of button.  false = stopped; true = playing
    
    var startingColor = UIColor(red: (253.0/255.0), green: (159.0/255.0), blue: (47.0/255.0), alpha: 1.0)
    var endingColor = UIColor(red: (255.0/255.0), green: (61.0/255.0), blue: (24.0/255.0), alpha: 1.0)
    
    var circle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 150.0, height: 150.0))
    var icon = BezierIconView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    var scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        circle.frame = CGRectMake(frame.width / 8, frame.height / 8, CGFloat( frame.width / 2), CGFloat( frame.height / 2) )
        
        icon.frame.size = CGSizeMake(circle.frame.size.width * (2/3), circle.frame.size.height * (2/3))
        icon.center = circle.center
        
        circle.layer.cornerRadius = circle.frame.height / 2
        circle.backgroundColor = startingColor
        
        icon.fillColor = UIColor.whiteColor()
    }
    
    convenience init () {
        self.init(frame:CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func didMoveToSuperview() {
        scaleAnimation.duration = 1.0
        scaleAnimation.repeatCount = HUGE
        scaleAnimation.autoreverses = true
        scaleAnimation.fromValue = NSNumber(float: 1.6)
        scaleAnimation.toValue = NSNumber(float: 1.4)
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.addSubview(circle)
        self.addSubview(icon)

        onTap(target: self, selector: "tapHandler:")
    }
    
    func tapHandler(sender: UITapGestureRecognizer) {
        var transformationColor:UIColor
        var scaleTransform:CGAffineTransform
        
        var completion: ((Bool) -> (Void))
        
        delegate?.statusChange()
        
        if (status) {
            transformationColor = startingColor
            scaleTransform = CGAffineTransformMakeScale(1.0, 1.0)
            self.circle.layer.removeAnimationForKey("scale")
            completion = { value in }
        } else {
            transformationColor = endingColor
            scaleTransform = CGAffineTransformMakeScale(1.6, 1.6)
            completion = {
                value in
                self.circle.layer.addAnimation(self.scaleAnimation, forKey: "scale")
            }
        }
        
        icon.prepareForTransition(status)
        let animations = {
            self.circle.backgroundColor = transformationColor
            self.circle.transform = scaleTransform
        }
        UIView.animateWithDuration(
            1.0,
            animations: animations,
            completion: completion
        )
        
        status = !status
    }

    func didAppear() {
        if status {
            self.circle.layer.addAnimation(self.scaleAnimation, forKey: "scale")
        }
    }
}
