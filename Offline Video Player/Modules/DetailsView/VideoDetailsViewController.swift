//
//  VideoDetailsViewController.swift
//  Offline Video Player
//
//  Created by Maneesh M on 28/02/23.
//

import UIKit
import SDWebImage
import AVKit


class VideoDetailsViewController: UIViewController {

    var viewModel: VideoDetailsViewModel!
    
    @IBOutlet weak var containerView: UIView!
    private let downloadProgressView = DownloadButtonView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var buttonPlayNext: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var isFullScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        DispatchQueue.main.async {
            self.downloadProgressView.setButtonEnabled(true)
            self.downloadProgressView.setButtonAction(self, action: #selector(self.downloadButtonTapped))
            self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.downloadProgressView)
            self.buttonPlayNext.contentHorizontalAlignment = .right
            self.parent?.navigationItem.largeTitleDisplayMode = .never
            self.decorate()
        }
        // Register for device orientation changes
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func decorate() {
        labelTitle.text = viewModel.selectedLesson.name
        labelDescription.text = viewModel.selectedLesson.description
        if let imageURLString = viewModel.selectedLesson.thumbnail {
            posterImageView.sd_setImage(with: URL(string: imageURLString))
        }
        playButton.imageView?.contentMode = .scaleAspectFit
    }
    func setupPlayer() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        containerView.layer.addSublayer(playerLayer)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = containerView.bounds
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
    
    @objc private func downloadButtonTapped() {
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
        
        let videoURL = URL(string: viewModel.selectedLesson.videoURL ?? "")
        setupPlayer()
        let playerItem = AVPlayerItem(url: videoURL!)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        posterImageView.isHidden = true
        

    }
    
}

