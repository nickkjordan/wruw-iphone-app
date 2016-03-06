import UIKit

protocol Status {
    func statusChange()
}

class AnimatedButton: UIView, UIGestureRecognizerDelegate {
    var delegate: Status?
    
    var status = false // status of button.  false = stopped; true = playing

    var scaleAnimation = CABasicAnimation(keyPath: "transform.scale")

    override func didMoveToSuperview() {
        scaleAnimation.duration = 1.0
        scaleAnimation.repeatCount = HUGE
        scaleAnimation.autoreverses = true
        scaleAnimation.fromValue = NSNumber(float: 1.6)
        scaleAnimation.toValue = NSNumber(float: 1.4)
        scaleAnimation.timingFunction =
            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.addSubview(circleView)
        self.addSubview(iconView)

        onTap(target: self, selector: "tapHandler:")
    }

    lazy var circleView: UIView = {
        let circleView = CircleView()
            .backgroundColor(ThemeManager.current().streamButtonOrangeColor)

        circleView.frame = CGRectMake(
            self.frame.width / 8,
            self.frame.height / 8,
            CGFloat(self.frame.width / 2),
            CGFloat(self.frame.height / 2)
        )

        return circleView
    }()

    lazy var iconView: BezierIconView = {
        let iconView = BezierIconView()
        iconView.frame.size = CGSizeMake(
            self.circleView.frame.size.width * (2/3),
            self.circleView.frame.size.height * (2/3)
        )
        iconView.center = self.circleView.center
        iconView.fillColor = UIColor.whiteColor()

        return iconView
    }()

    func tapHandler(sender: UITapGestureRecognizer) {
        var transformationColor:UIColor
        var scaleTransform:CGAffineTransform
        
        var completion: ((Bool) -> (Void))
        
        delegate?.statusChange()
        
        if (status) {
            transformationColor = ThemeManager.current().streamButtonOrangeColor
            scaleTransform = CGAffineTransformMakeScale(1.0, 1.0)
            self.circleView.layer.removeAnimationForKey("scale")
            completion = { value in }
        } else {
            transformationColor = ThemeManager.current().streamButtonRedColor
            scaleTransform = CGAffineTransformMakeScale(1.6, 1.6)
            completion = {
                value in
                self.circleView.layer
                    .addAnimation(self.scaleAnimation, forKey: "scale")
            }
        }
        
        iconView.prepareForTransition(status)
        let animations = {
            self.circleView.backgroundColor = transformationColor
            self.circleView.transform = scaleTransform
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
            self.circleView.layer
                .addAnimation(self.scaleAnimation, forKey: "scale")
        }
    }
}
