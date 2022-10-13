//
//  PlayBackViewController.swift
//  VideoRecorder
//
//  Created by 신동원 on 2022/10/11.
//

import UIKit
import Photos
import AVKit

//영상 재생 화면
class PlayBackViewController: UIViewController {

    private let player = AVPlayer()
    private let asset: PHAsset

    private lazy var playerViewController: AVPlayerViewController = {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = true
        controller.player = player
        return controller
    }()

    init(with asset: PHAsset) {
        self.asset = asset

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { avAsset, _, _ in
            guard let avAsset = avAsset else { return }
            let playerItem = AVPlayerItem(asset: avAsset)
            self.player.replaceCurrentItem(with: playerItem)
        }
        setupNavigation()
        setupViews()
        //        player.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        player.pause()
    }

    private func setupViews() {
        guard let playerView = playerViewController.view else {
            fatalError("Unable to get player view controller view.")
        }
        addChildViewController(playerViewController, toContainerView: view)
        playerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func setupNavigation() {
        navigationItem.title = asset.originalFilename
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .label
    }
}
