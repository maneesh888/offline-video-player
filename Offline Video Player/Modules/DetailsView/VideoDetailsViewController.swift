//
//  VideoDetailsViewController.swift
//  Offline Video Player
//
//  Created by Maneesh M on 28/02/23.
//

import UIKit
import SDWebImage
import AVKit
import Combine


class VideoDetailsViewController: UIViewController {

    var viewModel: VideoDetailsViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet weak var containerView: UIView!
    private let downloadProgressView = DownloadButtonView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var buttonPlayNext: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    private var isFullScreen = false
    
    private var isBuffering = true
    private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        DispatchQueue.main.async {
            self.downloadProgressView.setButtonEnabled(true)
            self.downloadProgressView.setButtonAction(self, action: #selector(self.downloadButtonTapped))
            self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.downloadProgressView)
            self.buttonPlayNext.contentHorizontalAlignment = .right
            self.parent?.navigationItem.largeTitleDisplayMode = .never
            
        }
        self.decorate()
        
    }
    
    private func decorate() {
        
        
        
        labelTitle.text = viewModel.selectedLesson.name
        labelDescription.text = viewModel.selectedLesson.description
        if let imageURLString = viewModel.selectedLesson.thumbnail {
            posterImageView.sd_setImage(with: URL(string: imageURLString))
        }
        playButton.imageView?.contentMode = .scaleAspectFit
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        containerView.addSubview(activityIndicator)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(contentViewTapped))
        containerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func registerNotifications() {
        
        // Register for device orientation changes
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // Register for AVPlayerItem notifications
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemPlaybackStalled), name: .AVPlayerItemPlaybackStalled, object: playerItem)
        
        // Register for AVPlayer notifications
                player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new], context: nil)
    }
    
   private func setupPlayer() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        containerView.layer.addSublayer(playerLayer!)
        registerNotifications()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer?.frame = containerView.bounds
        activityIndicator.center = playButton.center
        
    }
    
    @objc private func orientationDidChange() {
        if UIDevice.current.orientation.isLandscape && !isFullScreen {
            // Enter full screen mode
            isFullScreen = true
            let fullScreenVC = AVPlayerViewController()
            fullScreenVC.player = player
            present(fullScreenVC, animated: false, completion: nil)
        } else if UIDevice.current.orientation.isPortrait && isFullScreen {
            // Exit full screen mode
            isFullScreen = false
            dismiss(animated: false, completion: nil)
        }
    }
    
    @objc private func playerItemDidPlayToEndTime() {
            // Reset the player and show the play button
        player?.seek(to: .zero)
            player?.pause()
            playButton.isHidden = false
            activityIndicator.stopAnimating()
        }
        
        @objc private func playerItemPlaybackStalled() {
            // Show the activity indicator and hide the play button
            isBuffering = true
            playButton.isHidden = true
            activityIndicator.startAnimating()
        }
    
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            // Detect changes to the AVPlayer's timeControlStatus property
            if keyPath == "timeControlStatus", let status = player?.timeControlStatus {
                if status == .playing && isBuffering {
                    // The player has started playing after buffering
                    isBuffering = false
                    activityIndicator.stopAnimating()
                    playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                }
                
                if status == .paused {
                    playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                }
                if status == .waitingToPlayAtSpecifiedRate {
                    playButton.isHidden = true
                }
                //playButton.isHidden = !(status != .playing)
            }
            
            
        }
    
    @objc func contentViewTapped() {
        // Do something when the view is tapped
        playButton.isHidden = false
    }
    
    @objc private func downloadButtonTapped() {
        
        viewModel.downloadSelectedVideo()
        
//        // Start downloading
//        downloadProgressView.setProgress(0)
//        downloadProgressView.setButtonEnabled(false)
//        downloadProgressView.setStatus(.waiting)
//
//        // Simulate progress update
//        var progress: Float = 0
//        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//            progress += 0.1
//            if progress >= 1 {
//                timer.invalidate()
//                self.downloadProgressView.setButtonEnabled(true)
//                self.downloadProgressView.setStatus(.success)
//            } else {
//                self.downloadProgressView.setStatus(.downloading)
//                self.downloadProgressView.setProgress(progress)
//            }
//        }
//        timer.fire()
    }
    @IBAction func didTapPlay(_ sender: Any) {
        
        if player?.timeControlStatus == .playing || player?.timeControlStatus == .waitingToPlayAtSpecifiedRate {
            player?.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            return
        }
        
        if player?.timeControlStatus == .paused {
            player?.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            return
        }
        
        let videoURL = URL(string: viewModel.selectedLesson.videoURL ?? "")
        setupPlayer()
        let playerItem = AVPlayerItem(url: videoURL!)
        self.playerItem = playerItem
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
        posterImageView.isHidden = true
        activityIndicator.startAnimating()
        

    }
    
    deinit {
        // Remove observers
    }
    
}

