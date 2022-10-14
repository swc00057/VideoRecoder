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
    // MARK: - IBOutlet
    
    //@IBOutlet weak var imgTopShadow: UIImageView!
    
    // MARK: - Properties
    let mainView = VideoPlayerView()
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var isVideoPlaying = false
    private var isPlayerViewHide = true
    private var puseTime: CMTime = .zero
    private var timer: Timer?
    var orientation: NSLayoutConstraint?
    var asset: AVAsset
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView()
        aiv.tintColor = .white
        aiv.color = .white
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
    private lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        let image = UIImage(named: "ic_Play")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.isHidden = false
        button.addTarget(self, action: #selector(onBtnPlay(_:)), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - LifeCycle
    
    init(asset: AVAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            self.mainView.lblDurationTime.text = player.currentItem!.duration.durationText
        }
        
        if keyPath == "currentItem.loadedTimeRanges" {
            mainView.sliderTime.isUserInteractionEnabled = true
            activityIndicatorView.stopAnimating()
        }
    }
    
    // MARK: - Function
    private func setupUI() {
        setupVideoTimeSlider()
        setupPlayer()
        setupNavigation()
    }
    
    private func setupNavigation() {
        navigationItem.title = "asset.originalFilename"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .label
    }
    
    private func setupVideoTimeSlider() {
        //mainView.sliderTime.setThumbImage(sliderTimeimgView.image, for: .normal)
        //mainView.sliderTime.setThumbImage(sliderTimeimgView.image, for: .selected)
        
        mainView.btnMute.addTarget(self, action: #selector(onBtnMute), for: .touchUpInside)
        mainView.sliderTime.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        mainView.sliderTime.isUserInteractionEnabled = false
    }
    
    private func setupPlayer() {
        activityIndicatorView.startAnimating()
        //let urlString =  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        //        URL(string: urlString)  Bundle.main.url(forResource: "free", withExtension: "mp4")
        //if let asset = self.asset {
        let item = AVPlayerItem(asset: self.asset)
            player = AVPlayer(playerItem: item)
            player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            
            onBtnPlayPause()
            
            addTimeObserver()
            addObserverToVideoisEnd()
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            mainView.videoView.layer.addSublayer(playerLayer)
            setupPlayButtonInsideVideoView()
        //}
    }
    
    private func addObserverToVideoisEnd() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndPlay), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
            guard let currentItem = self!.player.currentItem else {return}
            if self?.player.currentItem!.status == .readyToPlay {
                self?.mainView.sliderTime.minimumValue = 0
                self?.mainView.sliderTime.maximumValue = Float(currentItem.duration.seconds)
                self?.mainView.sliderTime.value = Float(time.seconds)
                self?.mainView.lblCurrentTime.text = time.durationText
            }
        }
    }
    
    private func setupPlayButtonInsideVideoView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.someAction(_:)))
        self.mainView.videoView.addGestureRecognizer(gesture)
        
        mainView.videoView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: mainView.videoView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: mainView.videoView.centerYAnchor).isActive = true
        
        mainView.viewPlayerDetails.addSubview(pausePlayButton)
        pausePlayButton.centerXAnchor.constraint(equalTo: mainView.viewPlayerDetails.centerXAnchor).isActive = true
        pausePlayButton.bottomAnchor.constraint(equalTo: mainView.sliderTime.topAnchor, constant: -6).isActive = true
        pausePlayButton.widthAnchor.constraint(equalTo: mainView.viewPlayerDetails.heightAnchor, multiplier: 0.28).isActive = true
        pausePlayButton.heightAnchor.constraint(equalTo: pausePlayButton.widthAnchor).isActive = true
    }
    
    private func onBtnPlayPause() {
        if isVideoPlaying {
            player.pause()
            pausePlayButton.setImage(UIImage(named: "ic_Play"), for: .normal)
            isVideoPlaying = false
        } else {
            player.play()
            pausePlayButton.setImage(UIImage(named: "ic_Pause"), for: .normal)
            isVideoPlaying = true
        }
        self.hideshowPlayerView()
    }
    
    private func hideshowPlayerView(isViewTouch: Bool = false) {
        
        if isPlayerViewHide {
            
            self.pausePlayButton.isHidden = false
            self.mainView.viewPlayerDetails.isHidden = false
            self.isPlayerViewHide = false

        } else {
            if isViewTouch {
                self.pausePlayButton.isHidden = true
                self.mainView.viewPlayerDetails.isHidden = true
                self.isPlayerViewHide = true
            }
            
        }
        self.timer?.invalidate()
        if isPlayerViewHide == false && isVideoPlaying {
            self.timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] timer in
                if self?.isPlayerViewHide == false && self!.isVideoPlaying {
                    UIView.transition(with: self!.mainView.viewPlayerDetails, duration: 0.3,
                                      options: .transitionCrossDissolve,
                                      animations: {
                        self?.pausePlayButton.isHidden = true
                        self?.mainView.viewPlayerDetails.isHidden = true
                        self?.isPlayerViewHide = true
                    })
                }
            }
        }
    }
    
    
    @objc private func sliderValueChange(_ sender: UISlider) {
        let seekingCM = CMTimeMake(value: Int64(sender.value * Float(puseTime.timescale)), timescale: puseTime.timescale)
        mainView.lblCurrentTime.text = seekingCM.durationText
        player.seek(to: seekingCM)
    }
    
    @objc private func onBtnMute(_ sender: UIButton) {
        if isPlayerViewHide == false {
            timer?.invalidate()
            hideshowPlayerView()
        }
        mainView.btnMute.isSelected.toggle()
        if mainView.btnMute.isSelected {
            mainView.btnMute.isSelected = true
            player.isMuted = true
        } else {
            mainView.btnMute.isSelected = false
            player.isMuted = false
        }
    }
    
    // MARK: - Event
    @objc private func onBtnPlay(_ sender: Any) {
        onBtnPlayPause()
    }
    
    @objc private func someAction(_ sender: UITapGestureRecognizer) {
        self.hideshowPlayerView(isViewTouch: true)
    }
    
    @objc private func playerEndPlay() {
        onBtnPlayPause()
        isPlayerViewHide = true
        hideshowPlayerView()
        player.seek(to: CMTime.zero)
    }
    
}


