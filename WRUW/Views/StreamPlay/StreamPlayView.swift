import UIKit
import AVFoundation
import MediaPlayer

@objc class StreamPlayView: UIView {
    let urlAddress = "http://wruw-stream.wruw.org:8000/stream128.mp3"

    var viewModel: StreamPlayViewModel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        viewModel = StreamPlayViewModel(streamPath: urlAddress)
        addSubview(animatedPlayPauseButton) { make in
            make.edges.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    fileprivate lazy var animatedPlayPauseButton: AnimatedButton = {
        return AnimatedButton(viewModel: self.viewModel)
            .onTap(self, selector: #selector(didTapPlayer))
    }()

    @objc func didTapPlayer() {
        viewModel.changePlayerStatus()
    }

    @objc func didAppear() {
        animatedPlayPauseButton.didAppear()
    }
}
