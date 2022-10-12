//
//  RecodingViewController.swift
//  VideoRecorder
//
//  Created by 신동원 on 2022/10/11.
//

import UIKit
import AVKit

//영상 녹화 화면
class RecodingViewController: UIViewController {

    private let player = AVPlayer()

    private var video: Video

    private lazy var playerViewController: AVPlayerViewController = {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = true
        controller.player = player
        return controller
    }()

    init(with video: Video) {
        self.video = video
        // let playerItem = AVPlayerItem(url: video.url)
        let url = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil)?.last
        let playerItem = AVPlayerItem(url: url!)
        player.replaceCurrentItem(with: playerItem)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
        navigationItem.title = video.title
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .label
    }
}

