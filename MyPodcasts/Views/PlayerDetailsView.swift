//
//  PlayerDetailsView.swift
//  MyPodcasts
//
//  Created by Oleg Kudimov on 6/28/20.
//  Copyright © 2020 Oleg Kudimov. All rights reserved.
//

import UIKit
import  AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
    
    var episode: Episode! {
        didSet {
            miniTitleLabel.text = episode.title
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            playEpisode()
            
            guard let url = URL(string: episode.imageURL ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
            miniEpisodeImageView.sd_setImage(with: url)
        
        }
    }
    
    var panGesture: UIPanGestureRecognizer!
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    
    fileprivate func playEpisode() {
        print("Trying to play episode at url: ", episode.streamURL)
        
        guard let url = URL(string: episode.streamURL) else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in

            self?.currentTimeLabel.text = time.toDisplayString()
            
            if let durationTime = self?.player.currentItem?.duration, self?.player.currentItem?.status == .readyToPlay {
                self?.durationLabel.text = durationTime.toDisplayString()
                self?.currentTimeSlider.value = Float(CMTimeGetSeconds(time)) / Float(CMTimeGetSeconds(durationTime))
            }

            self?.updateCurrentTimeSlider()
            
        }
    }
    
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        
        self.currentTimeSlider.value = Float(percentage)
    }
    
    
    
    
    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan)))
        
    }
    
    
    @objc func handleDismissPan(gesture: UIPanGestureRecognizer) {
        print("maximizedStackView dismiss")
        
        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.maximizedStackView.transform = .identity
                
                if translation.y > 50 {
                    UIApplication.mainTabBarController()?.minimizePlayerDetails()
                    
                }
            })
        }
        
    }
    
    //Playing sounds in the background. The sound won't play without this code
    fileprivate func setupAudioSession() {
        do {
            
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch let sessionErr {
            print("failed to activate session:", sessionErr)
        }
        
    }
    
    //Setting up control center
    fileprivate func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            print("Should play podcast")
            
            self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            return .success
        }
        
        //accept command from headphones
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.handlePlayPause()
//            if self.player.timeControlStatus == .playing {
//                self.player.pause()
//            } else {
//                self.player.play()
//            }
            return .success
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //setup remote control function from control center
        setupRemoteControl()
        //setup audio session
        setupAudioSession()
        
        setupGestures()
        
        observePlayerCurrentTime()
        
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        // player has a reference to self
        // self has a reference to player
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("Episode started playing...")
            self?.enlargeEpisodeImageView()
        }
    }
    
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    
    deinit {
        print("PlayerDetailsView memory being reclaimed...")
    }
    
    //MARK:- IB Actions and Outlets
    
 
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var miniFastForwardButton: UIButton! {
        didSet {
            miniFastForwardButton.addTarget(self, action: #selector(handleFastForward(_:)), for: .touchUpInside)
        }
    }
    
    
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var maximizedStackView: UIStackView!
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: UISlider) {
        print("Slider Value: ", currentTimeSlider.value)
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    
    @IBAction func handleRewind(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }
    
    
    @IBAction func handleFastForward(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!

    
    @IBAction func handleDismiss(_ sender: UIButton) {
        //self.removeFromSuperview()
        UIApplication.mainTabBarController()?.minimizePlayerDetails()
    }
    
    
    fileprivate func enlargeEpisodeImageView() {
         UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
         
         self.episodeImageView.transform = .identity})
    }
    
    
    fileprivate let  shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    fileprivate func shrinkEpisodeImageView() {
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.episodeImageView.transform = self.shrunkenTransform
        })
    }

    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysOriginal), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @objc func handlePlayPause() {
        print("Trying to play and pause")
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysOriginal), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysOriginal), for: .normal)
            enlargeEpisodeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysOriginal), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysOriginal), for: .normal)
            shrinkEpisodeImageView()
        }
    }
    
    
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            // do some episodeImage modification
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = shrunkenTransform
        }
        
        
    }
    
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    
    
    
}
