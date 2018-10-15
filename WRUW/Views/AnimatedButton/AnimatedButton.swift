import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

protocol AnimatedButtonProtocol {
    var buttonIsAnimated: Observable<Bool> { get }
}

class AnimatedButton: UIView {
    init(viewModel: AnimatedButtonProtocol) {
        super.init(frame: .zero)

        viewModel.buttonIsAnimated
            .skip(1)
            .distinctUntilChanged()
            .bind(to: animationIsActive)
            .disposed(by: rx.disposeBag)

        addSubview(circleView) { make in
            make.height.width.equalTo(self.snp.height).dividedBy(2)
            make.center.equalTo(self)
        }
        addSubview(playStopIconView) { make in
            make.center.equalTo(self)
            make.height.width.equalTo(self.snp.height).dividedBy(3)
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Views

    fileprivate lazy var circleView: UIView = {
        return CircleView()
            .backgroundColor(ThemeManager.current().streamButtonOrangeColor)
    }()

    fileprivate lazy var playStopIconView =
        PlayStopIconView(fillColor: UIColor.white)

    // MARK: - Observables

    fileprivate lazy var animationIsActive: BehaviorRelay<Bool> = {
        let animationIsActive = BehaviorRelay(value: false)
        animationIsActive.asObservable()
            .subscribe(onNext: { self.activateAnimation($0) })
            .disposed(by: self.rx.disposeBag)
        return animationIsActive
    }()

    // MARK: - Animation

    fileprivate func activateAnimation(_ active: Bool) {
        self.circleView.layer.removeAllAnimations()

        playStopIconView.showPlayIcon(!active)

        let animations = active ? playingColorAndScale : stoppedColorAndScale
        let completion = active ? playingCompletion : nil

        UIView.animate(
            withDuration: 1.0,
            animations: animations,
            completion: completion
        )
    }

    fileprivate lazy var scaleAnimation: CABasicAnimation = {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 1.0
        scaleAnimation.repeatCount = HUGE
        scaleAnimation.autoreverses = true
        scaleAnimation.fromValue = NSNumber(value: 1.6 as Float)
        scaleAnimation.toValue = NSNumber(value: 1.4 as Float)
        scaleAnimation.timingFunction =
            CAMediaTimingFunction(name: .easeInEaseOut)
        return scaleAnimation
    }()

    fileprivate lazy var playingColorAndScale: () -> Void = {
        self.circleView.backgroundColor = ThemeManager.current().streamButtonRedColor
        self.circleView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
    }

    fileprivate lazy var stoppedColorAndScale: () -> Void = {
        self.circleView.backgroundColor = ThemeManager.current().streamButtonOrangeColor
        self.circleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }

    fileprivate lazy var playingCompletion: ((Bool) -> Void)? = { completed in
        guard completed else { return }

        self.circleView.layer.add(
            self.scaleAnimation,
            forKey: "scale"
        )
    }

    /// Function to reactivate animation when the view appears
    /// Likely must be called by view controller
    func didAppear() {
        if animationIsActive.value {
            self.circleView.layer
                .add(self.scaleAnimation, forKey: "scale")
        }
    }
}
