//
//  VideoDetailsViewController.swift
//  Offline Video Player
//
//  Created by Maneesh M on 28/02/23.
//

import UIKit
import SDWebImage


class VideoDetailsViewController: UIViewController {

    var viewModel: VideoDetailsViewModel!
    
    private let downloadProgressView = DownloadButtonView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var buttonPlayNext: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
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
        
    }
    
    func decorate() {
        labelTitle.text = viewModel.selectedLesson.name
        labelDescription.text = viewModel.selectedLesson.description
        if let imageURLString = viewModel.selectedLesson.thumbnail {
            posterImageView.sd_setImage(with: URL(string: imageURLString))
        }
        playButton.imageView?.contentMode = .scaleAspectFit
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
        let playerVC = ViewControllerFactory.getLessonPlayer(lesson: viewModel.selectedLesson)
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }
    
}

