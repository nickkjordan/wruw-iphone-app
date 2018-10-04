import UIKit
import MediaPlayer
import RxSwift
import RxCocoa
import NSObject_Rx

class StreamPlayViewModel: NSObject {
    var urlAddress: URL?

    init(streamPath: String) {
        urlAddress = URL(string: streamPath)

        super.init()
    }

    deinit {
        removeRemoteCommandEvents()
    }

    @objc func changePlayerStatus() {
        _audioPlayerIsActive.accept(!_audioPlayerIsActive.value)
    }

    // MARK: Audio Player

    fileprivate lazy var audioStreamPlayer: AVPlayer = {
        guard let urlStream = self.urlAddress else {
            return AVPlayer()
        }

        return AVPlayer(url: urlStream)
    }()

    fileprivate func audioPlayerIs(_ active: Bool) {
        active ? startPlayer() : pausePlayer()
    }

    fileprivate func startPlayer() {
        guard urlAddress != nil else {
            pausePlayer()
            return
        }

        if audioStreamPlayer.status == .readyToPlay {
            streamIsReadyToPlay()
            return
        }

        setupRemoteControlEvents()

        audioStreamPlayer.rx
            .observe(
                AVPlayer.Status.self,
                "status",
                options: .new,
                retainSelf: true
            )
            .filter { $0 == .readyToPlay }
            .subscribe(onNext: { [unowned self] _ in self.streamIsReadyToPlay() })
            .disposed(by: rx.disposeBag)
    }

    fileprivate func streamIsReadyToPlay() {
        audioStreamPlayer.play()

        setNowPlayingInfo(nowPlayingInfoPlaying)
    }

    fileprivate func pausePlayer() {
        audioStreamPlayer.pause()

        setNowPlayingInfo(nowPlayingInfoPaused)
    }

    // MARK: - MPRemoteCommandCenter

    fileprivate let changePlayerSelector = #selector(changePlayerStatus)

    fileprivate func setupRemoteControlEvents() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget(self, action: changePlayerSelector)
        commandCenter.pauseCommand.addTarget(self, action: changePlayerSelector)
    }

    fileprivate func removeRemoteCommandEvents() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.removeTarget(self, action: changePlayerSelector)
        commandCenter.pauseCommand.removeTarget(self, action: changePlayerSelector)
    }

    // MARK: - Observables for Playing/Paused status

    fileprivate lazy var _audioPlayerIsActive = BehaviorRelay(value: false)
    fileprivate lazy var _buttonIsAnimated: Observable<Bool> = {
        let buttonIsAnimated = self._audioPlayerIsActive.asObservable()
        buttonIsAnimated
            .skip(1)
            .subscribe(onNext: { [unowned self] play in self.audioPlayerIs(play) })
            .disposed(by: self.rx.disposeBag)
        return buttonIsAnimated
    }()

    // MARK: - Now Playing info

    fileprivate func setNowPlayingInfo(_ info: [String: Any]) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    fileprivate lazy var artworkImage: UIImage = {
        let bundle = Bundle.main
        if let path = bundle.path(forResource: "iTunesArtwork", ofType: "png"),
            let imageView = UIImage(contentsOfFile: path) {
            return imageView
        }

        return UIImage()
    }()

    fileprivate lazy var mediaItemArtwork: MPMediaItemArtwork = {
        MPMediaItemArtwork(image: self.artworkImage)
    }()

    fileprivate lazy var nowPlayingInfoPaused: [String: Any] = {
        return self.nowPlayingInfo +
            [MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 0.0)]
    }()

    fileprivate lazy var nowPlayingInfoPlaying: [String: Any] = {
        return self.nowPlayingInfo +
            [MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 1.0)]
    }()

    fileprivate lazy var nowPlayingInfo: [String: Any] = {
        return [
            MPMediaItemPropertyTitle: "Listening Live",
            MPMediaItemPropertyArtist: "WRUW - 91.1 FM",
            MPMediaItemPropertyArtwork: self.mediaItemArtwork
        ]
    }()
}

extension StreamPlayViewModel: AnimatedButtonProtocol {
    var buttonIsAnimated: Observable<Bool> { return _buttonIsAnimated }
}
