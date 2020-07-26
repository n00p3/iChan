//
//  VideoPlayerController.swift
//  iChan
//
//  Created by Mateusz Głowski on 26/07/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit
import MobileVLCKit

class VideoPlayerController : UIViewController, VLCMediaPlayerDelegate {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var controlsView: UIVisualEffectView!
    @IBOutlet weak var sliderView: UISlider!
    private var player: VLCMediaListPlayer?
    @IBOutlet weak var playPauseBtn: UIButton!
//    var videoURL = "https://i.4cdn.org/wsg/1594028421375.webm"
    var videoURL = "file:///Users/mateusz.glowski/Desktop/test_video.webm"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playPauseBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        var thumb = UIImage.scale(image: UIImage(systemName: "circle.fill")!, by: 0.5)
        thumb = thumb?.withTintColor(.white)
        sliderView.setThumbImage(thumb, for: .normal)
        sliderView.setThumbImage(thumb, for: .highlighted)
        
        controlsView.clipsToBounds = true
        controlsView.layer.cornerRadius = 10
        player = VLCMediaListPlayer(drawable: videoView)
        player?.mediaPlayer.delegate = self
        let media = VLCMediaList()
        media.add(VLCMedia(url: URL(string: videoURL)!))
        player?.mediaList = media
        player?.repeatMode = .repeatAllItems
        player?.play()
    }
  
    @IBAction func playPause(_ sender: Any) {
        if player!.mediaPlayer.isPlaying {
            player?.pause()
            playPauseBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player?.play()
            playPauseBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        print(player?.mediaPlayer.state)
    }
}
