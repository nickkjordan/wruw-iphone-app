import UIKit
import AVFoundation
import MediaPlayer

@objc class StreamPlayView: UIView  {
    // previous stream url = "http://wruw-stream.wruw.org:443/stream.mp3"
    // current stream url = "http://wruw-stream2.wruw.org:8000/stream256.mp3"
    let urlAddress = "http://wruw-stream2.wruw.org:8000/stream256.mp3"





    }()
    var viewModel: StreamPlayViewModel!

    override init(frame: CGRect) {
        super.init(frame: frame)

    override func didMoveToSuperview() {
        viewModel = StreamPlayViewModel(streamPath: urlAddress)
        self.addSubview(animatedPlayPauseButton)
    }
    
    @objc func didAppear() {
        animatedPlayPauseButton.didAppear()
    }


        )

    override func canBecomeFirstResponder() -> Bool {
        return true;
    }

    }

    }
}
