import UIKit
import RxSwift
import NSObject_Rx

protocol AnimatedButtonProtocol {
    var buttonIsAnimated: Observable<Bool> { get }
}

class AnimatedButton: UIView {
    init(viewModel: AnimatedButtonProtocol) {
        super.init(frame: CGRectZero)

        viewModel.buttonIsAnimated
            .skip(1)
            .distinctUntilChanged()
            .bindTo(animationIsActive)
            .addDisposableTo(rx_disposeBag)

        addSubview(circleView) { make in
            make.height.width.equalTo(self.snp_height).dividedBy(2)
            make.center.equalTo(self)
        }
        addSubview(playStopIconView) { make in
            make.center.equalTo(self)
            make.height.width.equalTo(self.snp_height).dividedBy(3)
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Views
    
    private lazy var circleView: UIView = {
        return CircleView()
            .backgroundColor(ThemeManager.current().streamButtonOrangeColor)
    }()

    private lazy var playStopIconView =
        PlayStopIconView(fillColor: UIColor.whiteColor())

    // MARK: - Observables

    private lazy var animationIsActive: Variable<Bool> = {
        let animationIsActive = Variable(false)
        animationIsActive.asObservable()
            .subscribeNext { self.activateAnimation($0) }
            .addDisposableTo(self.rx_disposeBag)
        return animationIsActive
    }()

    // MARK: - Animation

    lazy var scaleAnimation: CABasicAnimation = {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 1.0
        scaleAnimation.repeatCount = HUGE
        scaleAnimation.autoreverses = true
        scaleAnimation.fromValue = NSNumber(float: 1.6)
        scaleAnimation.toValue = NSNumber(float: 1.4)
        scaleAnimation.timingFunction =
            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        return scaleAnimation
    }()

    func activateAnimation(active: Bool) {
        var transformationColor:UIColor
        var scaleTransform:CGAffineTransform
        
        var completion: ((Bool) -> (Void))

        if !active {
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

        playStopIconView.showPlayIcon(!active)
        let animations = {
            self.circleView.backgroundColor = transformationColor
            self.circleView.transform = scaleTransform
        }
        UIView.animateWithDuration(
            1.0,
            animations: animations,
            completion: completion
        )
    }

    func didAppear() {
        if animationIsActive.value {
            self.circleView.layer
                .addAnimation(self.scaleAnimation, forKey: "scale")
        }
    }
}
