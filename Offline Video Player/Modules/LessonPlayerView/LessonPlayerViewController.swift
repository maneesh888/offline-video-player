//
//  LessonPlayerViewController.swift
//  Offline Video Player
//
//  Created by Maneesh M on 01/03/23.
//

import UIKit
import Combine
import AVKit


class LessonPlayerViewController: UIViewController {

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var avplayerItem: AVPlayerItem?
    private var playerViewController: AVPlayerViewController?

    var viewModel:LessonPlayerViewModel!
    /// Holds all subscription references
    private var subscriptions = Set<AnyCancellable>()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        .landscape
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupPlayerView()
        if let urlString = viewModel.assetPath, let videoURL = URL(string: urlString)  {
            self.loadVideoWithURL(videoURL)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    func stopPlayBack() {
        self.avplayerItem = nil
        self.player?.replaceCurrentItem(with: nil)
        self.playerViewController = nil
    }
    
    private  func setupPlayerView(){
        guard self.playerLayer == nil else {return}
        
        let playerViewController = AVPlayerViewController()
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.frame = view.bounds
        playerViewController.didMove(toParent: self)
        self.playerViewController = playerViewController

    }
    
    private func loadVideoWithURL(_ videoURL:URL){
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        self.avplayerItem = playerItem
        player = AVPlayer(playerItem: playerItem)
        playerViewController?.player = self.player
        player?.play()

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let isLandscape = UIDevice.current.orientation.isLandscape
        playerLayer?.frame = isLandscape ? CGRect(origin: .zero, size: size) : view.bounds
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")


    }

    deinit {
        print("Player View Deinit")
    }

}
