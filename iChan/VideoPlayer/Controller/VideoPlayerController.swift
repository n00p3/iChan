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
    @IBOutlet weak var videoTimeLabel: UILabel!
    @IBOutlet weak var videoRemainingTimeLabel: UILabel!
    private var player: VLCMediaListPlayer?
    @IBOutlet weak var playPauseBtn: UIButton!
//    var videoURL = "https://i.4cdn.org/wsg/1594028421375.webm"
    var videoURL = "file:///Users/mateusz.glowski/Desktop/test_video.webm"
    var timer: Timer?
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    @objc private func sliderValueWillChange() {
        timer?.invalidate()
    }
    
    @objc private func sliderValueDidChanged() {
        let newTime = sliderView.value * Float(player?.mediaPlayer.media.length.intValue ?? Int32(0))
        player?.mediaPlayer.time = VLCTime(int: Int32(newTime))
        createTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playPauseBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        var thumb = UIImage.scale(image: UIImage(systemName: "circle.fill")!, by: 0.5)
        thumb = thumb?.withTintColor(.white)
        sliderView.setThumbImage(thumb, for: .normal)
        sliderView.setThumbImage(thumb, for: .highlighted)
  
        sliderView.addTarget(self, action: #selector(sliderValueWillChange), for: .touchDown)
        sliderView.addTarget(self, action: #selector(sliderValueDidChanged), for: .touchUpInside)
        // TODO: Implement later.
//        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView(_:)))
//        videoView.addGestureRecognizer(pinch)
  
        controlsView.clipsToBounds = true
        controlsView.layer.cornerRadius = 10
        player = VLCMediaListPlayer(drawable: videoView)
        player?.mediaPlayer.delegate = self
        let media = VLCMediaList()
        media.add(VLCMedia(url: URL(string: videoURL)!))
        player?.mediaList = media
        player?.repeatMode = .repeatAllItems
        player?.play()
        
        createTimer()
    }
    
    private func createTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            self.videoTimeLabel.text = self.player?.mediaPlayer.time.stringValue
            self.videoRemainingTimeLabel.text = self.player?.mediaPlayer.remainingTime.stringValue
            if self.player?.mediaPlayer.time.intValue != nil && self.player?.mediaPlayer.media?.length.intValue != nil {
                let progress = Float(self.player!.mediaPlayer.time.intValue) / Float(self.player!.mediaPlayer.media.length.intValue)
                self.sliderView.setValue(progress, animated: true)
            }
        })
    }
    
//    @objc private func pinchedView(_ sender: UIPinchGestureRecognizer) {
//        let trans = CGAffineTransform(
//            scaleX: sender.scale,
//            y: sender.scale)
//        videoView.transform = trans
//    }
  
    
    
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
