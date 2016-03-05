import UIKit
import AVFoundation
import MediaPlayer

@objc class StreamPlayView: UIView, Status {
    let urlAddress = NSURL(string: "http://wruw-stream.wruw.org:443/stream.mp3")
    var player = AVPlayer?()
    var view = AnimatedButton(frame: CGRectMake(10, 10, 150, 150))
    let path = NSBundle.mainBundle().pathForResource("Default", ofType: "png")
    var image = UIImage()

    override func didMoveToSuperview() {
        view.delegate = self
        
        self.addSubview(view)
        if let path = path {
            image = UIImage(contentsOfFile: path)!
        }
    }
    
    @objc func didAppear() {
        view.didAppear()
    }
    
    func statusChange() {
        if(player?.rate == 1.0)//means pause
        {
            player?.pause()
            player?.removeObserver(self, forKeyPath: "status")
            
            let artwork = MPMediaItemArtwork(image: image)
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
                MPMediaItemPropertyTitle : "Listening Live",
                MPMediaItemPropertyArtist : "WRUW - 91.1 FM",
                MPMediaItemPropertyArtwork : artwork,
                MPNowPlayingInfoPropertyPlaybackRate : 0.0
            ]
        }

        else {
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
        
        let artwork = MPMediaItemArtwork(image: image)
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
            MPMediaItemPropertyTitle: "Listening Live",
            MPMediaItemPropertyArtist: "WRUW - 91.1 FM",
            MPMediaItemPropertyArtwork: artwork,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0
        ]
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
        let p = player
        print("received remote control \(rc.rawValue)", terminator: "") // 101 = pause, 100 = play

        switch (rc) {
        case .RemoteControlTogglePlayPause:
            view.tapHandler(UITapGestureRecognizer())

        case .RemoteControlPlay:
            view.tapHandler(UITapGestureRecognizer())

        case .RemoteControlPause:
            view.tapHandler(UITapGestureRecognizer())

        default:break
        }
    }
}
