//
//  StreamPlayView.swift
//  WRUW
//
//  Created by Nick Jordan on 3/23/15.
//  Copyright (c) 2015 Nick Jordan. All rights reserved.
//

import UIKit
import AVFoundation

class StreamPlayView: UIView, Status {
    
    let urlAddress = NSURL(string: "http://wruw-stream.wruw.org:443/stream.mp3")
    var player = AVPlayer?()

    override func didMoveToSuperview() {
        var view = AnimatedButton(frame: CGRectMake(10, 10, 150, 150))
        view.delegate = self
        
        self.addSubview(view)
    }
    
    func statusChange() {
        if(player?.rate == 1.0)//means pause
        {
            player?.pause()
        }
        else {
            // Create a URL object.
            // And send it to the avplayer
            if let play = player as AVPlayer? {
                player?.removeObserver(self, forKeyPath: "status")
            }
            player = AVPlayer(URL: urlAddress)

            player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == "status") {
            if (player?.status == AVPlayerStatus.ReadyToPlay) {
                player?.play()
            } else if (player?.status == AVPlayerStatus.Failed) {
                /* An error was encountered */
            }
        }
    }
    
}
