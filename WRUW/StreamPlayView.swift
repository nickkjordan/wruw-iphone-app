import UIKit
import AVFoundation
import MediaPlayer

@objc class StreamPlayView: UIView, Status {
    // previous stream url = "http://wruw-stream.wruw.org:443/stream.mp3"
    // current stream url = "http://wruw-stream2.wruw.org:8000/stream256.mp3"
    let urlAddress = NSURL(string: "http://wruw-stream2.wruw.org:8000/stream256.mp3")
    private var player = AVPlayer?()

    private lazy var animatedPlayPauseButton: AnimatedButton = {
        return AnimatedButton(frame: CGRectMake(10, 10, 150, 150), delegate: self)
    }()

    private lazy var artworkImage: UIImage = {
        let bundle = NSBundle.mainBundle()
        if let path = bundle.pathForResource("Default", ofType: "png"),
            imageView = UIImage(contentsOfFile: path) {
            return imageView
        }

        return UIImage()
    }()

    private lazy var mediaItemArtwork: MPMediaItemArtwork = {
        MPMediaItemArtwork(image: self.artworkImage)
    }()

    private lazy var nowPlayingInfoPaused: [String: AnyObject] = {
        return self.nowPlayingInfo + [MPNowPlayingInfoPropertyPlaybackRate: 0.0]
    }()

    private lazy var nowPlayingInfoPlaying: [String: AnyObject] = {
        return self.nowPlayingInfo + [MPNowPlayingInfoPropertyPlaybackRate: 1.0]
    }()

    private lazy var nowPlayingInfo: [String : AnyObject] = {
        return [
            MPMediaItemPropertyTitle: "Listening Live",
            MPMediaItemPropertyArtist: "WRUW - 91.1 FM",
            MPMediaItemPropertyArtwork: self.mediaItemArtwork
        ]
    }()

    override func didMoveToSuperview() {
        self.addSubview(animatedPlayPauseButton)
    }
    
    @objc func didAppear() {
        animatedPlayPauseButton.didAppear()
    }
    
    func statusChange() {
        player?.rate == 1.0 ? pausePlayer() : startPlayer()
    }

    func startPlayer() {
        // Create a URL object.
        // And send it to the avplayer
        player = AVPlayer(URL: urlAddress!)

        player?.addObserver(
            self,
            forKeyPath: "status",
            options: NSKeyValueObservingOptions.New,
            context: nil
        )
    }

    func pausePlayer() {
            player?.pause()
            player?.removeObserver(self, forKeyPath: "status")
            
            setNowPlayingInfo(nowPlayingInfoPaused)
    }
    
    override func observeValueForKeyPath(
        keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>
    ) {
        guard keyPath == "status" else {
            return
        }

        guard player?.status == AVPlayerStatus.ReadyToPlay else {
            /* An error was encountered */
            return
        }

        player?.play()
        
        setNowPlayingInfo(nowPlayingInfoPlaying)
    }

    func setNowPlayingInfo(info: [String: AnyObject]) {
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info
    }

    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
    
    func registerForAudioObjectNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()

        notificationCenter.addObserver(
            self,
            selector: "handlePlaybackStateChanged",
            name: "MixerHostAudioObjectDidChange",
            object: player
        )
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        print(event!.subtype, terminator: "")
        let rc = event!.subtype
        print("received remote control \(rc.rawValue)", terminator: "") // 101 = pause, 100 = play

        guard rc == .RemoteControlTogglePlayPause ||
            rc == .RemoteControlPlay ||
            rc == .RemoteControlPause else {
            return
        }

        animatedPlayPauseButton.tapHandler(UITapGestureRecognizer())
    }
}
