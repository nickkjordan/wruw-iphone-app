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

    func changePlayerStatus() {
        _audioPlayerIsActive.value = !_audioPlayerIsActive.value
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

        audioStreamPlayer
            .rx_observe(
                AVPlayerStatus.self,
                "status",
                options: .New,
                retainSelf: true
            )
            .filter { $0 == .ReadyToPlay }
            .subscribeNext { [unowned self] _ in self.streamIsReadyToPlay() }
            .addDisposableTo(rx_disposeBag)
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

    fileprivate let changePlayerSelector: Selector = #selector(StreamPlayViewModel.changePlayerStatus)

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

    fileprivate lazy var _audioPlayerIsActive = Variable(false)
    fileprivate lazy var _buttonIsAnimated: Observable<Bool> = {
        let buttonIsAnimated = self._audioPlayerIsActive.asObservable()
        buttonIsAnimated
            .skip(1)
            .subscribeNext { [unowned self] play in self.audioPlayerIs(active: play) }
            .addDisposableTo(self.rx_disposeBag)
        return buttonIsAnimated
    }()

    // MARK: - Now Playing info

    fileprivate func setNowPlayingInfo(_ info: [String: AnyObject]) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    fileprivate lazy var artworkImage: UIImage = {
        let bundle = Bundle.main
        if let path = bundle.path(forResource: "Default", ofType: "png"),
            let imageView = UIImage(contentsOfFile: path) {
            return imageView
        }

        return UIImage()
    }()

    fileprivate lazy var mediaItemArtwork: MPMediaItemArtwork = {
        MPMediaItemArtwork(image: self.artworkImage)
    }()

    fileprivate lazy var nowPlayingInfoPaused: [String: AnyObject] = {
        return self.nowPlayingInfo +
            [MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 0.0 as Double)]
    }() as [String : AnyObject]

    fileprivate lazy var nowPlayingInfoPlaying: [String: AnyObject] = {
        return self.nowPlayingInfo +
            [MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 1.0 as Double)]
    }() as [String : AnyObject]

    fileprivate lazy var nowPlayingInfo: [String : Any] = {
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
