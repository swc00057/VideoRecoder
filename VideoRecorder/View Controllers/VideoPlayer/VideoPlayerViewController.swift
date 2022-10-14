//
//  VideoPlayerViewController.swift
//  VideoRecorder
//
//  Created by 신동원 on 2022/10/14.
//

import UIKit
import AVKit
import Photos

final class VideoPlayerViewController: UIViewController {

    // MARK: Constants

    private enum Image {
        static let play = UIImage(named: "ic_Play")
        static let pause = UIImage(named: "ic_Pause")
    }

    // MARK: UI

    private let mainView = VideoPlayerView()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.tintColor = .white
        view.color = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        return view
    }()

    private lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        let image = Image.play
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.isHidden = false
        button.addTarget(self, action: #selector(pausePlayButtonClicked), for: .touchUpInside)
        return button
    }()

    // MARK: Properties

    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var isVideoPlaying = false
    private var isPlayerViewHide = true
    private var puseTime: CMTime = .zero
    private var timer: Timer?

    var asset: AVAsset
    var fileName = "비디오"
    
    // MARK: Init
    
    init(asset: AVAsset) {
        self.asset = asset

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Life Cycle

    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = mainView.videoView.bounds
    }
    
    // MARK: Layout

    private func setupUI() {
        setupTarget()
        setupPlayer()
        setupNavigation()
    }

    private func setupTarget() {
        mainView.muteButton.addTarget(self, action: #selector(muteButtonClicked), for: .touchUpInside)
        mainView.timeSlider.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        mainView.timeSlider.isUserInteractionEnabled = false
    }

    private func setupPlayer() {
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)

        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        pausePlayButtonAction()

        addTimeObserver()
        addVideoDidEndObserver()

        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        mainView.videoView.layer.addSublayer(playerLayer)
        setupPlayButtonInsideVideoView()
    }

    private func setupNavigation() {
        navigationItem.title = fileName
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupPlayButtonInsideVideoView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.someAction))
        mainView.videoView.addGestureRecognizer(gesture)

        mainView.videoView.addSubview(activityIndicatorView)
        mainView.controlView.addSubview(pausePlayButton)

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: mainView.videoView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: mainView.videoView.centerYAnchor),

            pausePlayButton.centerXAnchor.constraint(equalTo: mainView.controlView.centerXAnchor),
            pausePlayButton.bottomAnchor.constraint(equalTo: mainView.timeSlider.topAnchor, constant: -6),
            pausePlayButton.widthAnchor.constraint(equalTo: mainView.controlView.heightAnchor, multiplier: 0.28),
            pausePlayButton.heightAnchor.constraint(equalTo: pausePlayButton.widthAnchor),
        ])
    }

    // MARK: Observer

    private func addVideoDidEndObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(endPlayVideo), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let currentItem = self!.player.currentItem else { return }

            if self?.player.currentItem!.status == .readyToPlay {
                self?.mainView.timeSlider.minimumValue = 0
                self?.mainView.timeSlider.maximumValue = Float(currentItem.duration.seconds)
                self?.mainView.timeSlider.value = Float(time.seconds)
                self?.mainView.currentTime.text = time.durationText
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration",
           let duration = player.currentItem?.duration.seconds,
           duration > 0.0 {
            self.mainView.durationTime.text = player.currentItem!.duration.durationText
        }

        if keyPath == "currentItem.loadedTimeRanges" {
            mainView.timeSlider.isUserInteractionEnabled = true
            activityIndicatorView.stopAnimating()
        }
    }

    // MARK: Action Handler

    @objc
    private func sliderValueChange(_ sender: UISlider) {
        let seek = CMTimeMake(value: Int64(sender.value * Float(puseTime.timescale)), timescale: puseTime.timescale)
        mainView.currentTime.text = seek.durationText
        player.seek(to: seek)
    }
    
    @objc
    private func muteButtonClicked() {
        if isPlayerViewHide == false {
            timer?.invalidate()
            hideshowPlayerView()
        }

        mainView.muteButton.isSelected.toggle()
        if mainView.muteButton.isSelected {
            mainView.muteButton.isSelected = true
            player.isMuted = true
        } else {
            mainView.muteButton.isSelected = false
            player.isMuted = false
        }
    }

    @objc
    private func pausePlayButtonClicked() {
        pausePlayButtonAction()
    }
    
    @objc
    private func someAction() {
        hideshowPlayerView(isViewTouch: true)
    }
    
    @objc
    private func endPlayVideo() {
        pausePlayButtonAction()
        isPlayerViewHide = true
        hideshowPlayerView()
        player.seek(to: .zero)
    }

    private func pausePlayButtonAction() {
        if isVideoPlaying {
            player.pause()
            pausePlayButton.setImage(Image.play, for: .normal)
            isVideoPlaying = false
        } else {
            player.play()
            pausePlayButton.setImage(Image.pause, for: .normal)
            isVideoPlaying = true
        }
        hideshowPlayerView()
    }

    private func hideshowPlayerView(isViewTouch: Bool = false) {
        if isPlayerViewHide {
            pausePlayButton.isHidden = false
            mainView.controlView.isHidden = false
            isPlayerViewHide = false
        } else {
            if isViewTouch {
                pausePlayButton.isHidden = true
                mainView.controlView.isHidden = true
                isPlayerViewHide = true
            }
        }
        timer?.invalidate()
        if isPlayerViewHide == false && isVideoPlaying {
            timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] timer in
                if self?.isPlayerViewHide == false &&
                    self!.isVideoPlaying {
                    UIView.transition(
                        with: self!.mainView.controlView, duration: 0.3,
                        options: .transitionCrossDissolve,
                        animations: {
                            self?.pausePlayButton.isHidden = true
                            self?.mainView.controlView.isHidden = true
                            self?.isPlayerViewHide = true
                        }
                    )
                }
            }
        }
    }
    
}


