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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        .portrait
    }
    
    override var shouldAutorotate: Bool{
        false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.setupNavigationBarItems()
        self.decorate()
        self.binding()
    }
    
    private func setupNavigationBarItems() {
        
        DispatchQueue.main.async {
            self.parent?.navigationItem.largeTitleDisplayMode = .never
            self.updateDownloadButton(state: self.viewModel.downloadState)
            self.downloadProgressView.setButtonAction(self, action: #selector(self.downloadButtonTapped))
            self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.downloadProgressView)
            self.buttonPlayNext.contentHorizontalAlignment = .right
            
            
        }
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
        buttonPlayNext.isHidden = viewModel.hideNextButton
        
        if viewModel.userInitiatedPlayback {
            self.startPlayback()
        }
    }
    
    private func binding(){
        
        viewModel.$selectedLesson
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lesson in
                // Update the UI with the new object
                guard let self = self else {return}
                self.stopPlayback()
                self.decorate()
                self.updateDownloadButton(state: self.viewModel.downloadState)
            }
            .store(in: &cancellables)
        
        viewModel.downloadProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (progress, state) in
                guard let self = self else { return }
                self.updateDownloadButton(progress: progress, state: state)
            }
            .store(in: &cancellables)
    }
    
    private func updateDownloadButton(progress:Double = 0.0,state: AssetDownloadState) {

        switch state {
            
        case .notDownloaded:
            self.downloadProgressView.setStatus(.canceled)
        case .waiting:
            self.downloadProgressView.setStatus(.waiting)
        case .downloading:
            self.downloadProgressView.setStatus(.downloading)
            self.downloadProgressView.setProgress(Float(progress))
        case .downloaded:
            self.downloadProgressView.setStatus(.success)
        }
    }
    
    private func addObservers() {
        
        // Register for device orientation changes
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // Register for AVPlayerItem notifications
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemPlaybackStalled), name: .AVPlayerItemPlaybackStalled, object: playerItem)
        
        // Register for AVPlayer notifications
                player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new], context: nil)
    }
    
    private func startPlayback() {
        guard let videoURL = viewModel.getURLForSelected() else {return}
        
        setupPlayer()
        let playerItem = AVPlayerItem(url: videoURL)
        self.playerItem = playerItem
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
        posterImageView.isHidden = true
        activityIndicator.startAnimating()
        viewModel.userInitiatedPlayback = true
    }
    
   private func setupPlayer() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        containerView.layer.addSublayer(playerLayer!)
       addObservers()
    }
    
    private func stopPlayback() {
        player?.replaceCurrentItem(with: nil)
        posterImageView.isHidden = false
        cleanup()
    }
    
    private func cleanup() {
        player = nil
        playerItem = nil
        NotificationCenter.default.removeObserver(self)
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    private func hidePlayButton() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.playButton.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer?.frame = containerView.bounds
        activityIndicator.center = playButton.center
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if playerItem != nil {
            addObservers()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isFullScreen {
            stopPlayback()
            viewModel = nil
        }
        
        
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
            hidePlayButton()
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
                    // Hide the button after 3 seconds
                    hidePlayButton()
                }
                //playButton.isHidden = !(status != .playing)
            }
            
            
        }
    
    @objc func contentViewTapped() {
        // Do something when the view is tapped
        playButton.isHidden = false
        hidePlayButton()
    }
    
    @objc private func downloadButtonTapped() {
        viewModel.downloadButtonAction()
    }
    
    @IBAction func didTapPlay(_ sender: Any) {
        
        
                
        if player?.timeControlStatus == .playing || player?.timeControlStatus == .waitingToPlayAtSpecifiedRate {
            player?.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            viewModel.userInitiatedPlayback = false
            return
        }
        
        if player?.timeControlStatus == .paused {
            player?.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            viewModel.userInitiatedPlayback = true
            return
        }
        
        startPlayback()
        

    }
    
    @IBAction func didTapNext(_ sender: Any) {
        viewModel.chooseNextLesson()
    }
    
    deinit {
        // Remove observers
        print("DEINIT \(self)")
    }
    
}

