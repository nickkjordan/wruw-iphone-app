//
//  StreamPlayView.swift
//  WRUW
//
//  Created by Nick Jordan on 3/23/15.
//  Copyright (c) 2015 Nick Jordan. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class StreamPlayView: UIView, Status {
    
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
    
    func statusChange() {
        if(player?.rate == 1.0)//means pause
        {
            player?.pause()
            player?.removeObserver(self, forKeyPath: "status")
            
            
            let artwork = MPMediaItemArtwork(image: image)
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo =
                [MPMediaItemPropertyTitle : "Listening Live",
                    MPMediaItemPropertyArtist : "WRUW - 91.1 FM",
                    MPMediaItemPropertyArtwork : artwork,
                    MPNowPlayingInfoPropertyPlaybackRate : 0.0]
        }
        else {
            // Create a URL object.
            // And send it to the avplayer
            if let play = player as AVPlayer? {

            }
            player = AVPlayer(URL: urlAddress)

            player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
            
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == "status") {
            if (player?.status == AVPlayerStatus.ReadyToPlay) {
                player?.play()
                
                let artwork = MPMediaItemArtwork(image: image)
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo =
                    [MPMediaItemPropertyTitle : "Listening Live",
                        MPMediaItemPropertyArtist : "WRUW - 91.1 FM",
                        MPMediaItemPropertyArtwork : artwork,
                        MPNowPlayingInfoPropertyPlaybackRate : 1.0]
            } else if (player?.status == AVPlayerStatus.Failed) {
                /* An error was encountered */
            }
        }
    }
    
    
    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
    
    func registerForAudioObjectNotifications() {
    
        let notificationCenter = NSNotificationCenter.defaultCenter() //[NSNotificationCenter defaultCenter];
    
        notificationCenter.addObserver(self, selector: "handlePlaybackStateChanged", name: "MixerHostAudioObjectDidChange", object: player)

    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        println(event.subtype)
        let rc = event.subtype
        let p = player
        println("received remote control \(rc.rawValue)") // 101 = pause, 100 = play
        switch rc {
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
