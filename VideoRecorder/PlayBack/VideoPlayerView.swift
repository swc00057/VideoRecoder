//
//  VideoPlayerView.swift
//  VideoRecorder
//
//  Created by 신동원 on 2022/10/14.
//

import UIKit

class VideoPlayerView: UIView {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let videoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let controlView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let currentTime: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.text = "00.00"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let durationTime: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.text = "00.00"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let timeSlider: UISlider = {
        let view = UISlider()
        view.minimumTrackTintColor = .yellow
        view.maximumTrackTintColor = .darkGray
        view.thumbTintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let muteButton: UIButton = {
        let view = UIButton()
        view.tintColor = .white
        view.setImage(UIImage(named: "unmute"), for: .normal)
        view.setImage(UIImage(named: "mute"), for: .selected)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupView() {
        
        addSubview(containerView)
        
        
        [videoView,controlView].forEach {
            containerView.addSubview($0)
        }
        
        [currentTime,durationTime,timeSlider,muteButton].forEach {
            controlView.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            
            
            containerView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            videoView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            videoView.topAnchor.constraint(equalTo: containerView.topAnchor),
            videoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            videoView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            controlView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            controlView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            controlView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            controlView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3),
            
            currentTime.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 20),
            currentTime.bottomAnchor.constraint(equalTo: controlView.bottomAnchor, constant: -8),
            
            durationTime.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -20),
            durationTime.bottomAnchor.constraint(equalTo: controlView.bottomAnchor, constant: -8),
            
            muteButton.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -20),
            muteButton.bottomAnchor.constraint(equalTo: currentTime.topAnchor, constant: -8),
            muteButton.widthAnchor.constraint(equalToConstant: 33),
            muteButton.heightAnchor.constraint(equalToConstant: 33),
            
            timeSlider.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 20),
            timeSlider.trailingAnchor.constraint(equalTo: muteButton.leadingAnchor, constant: -8),
            timeSlider.bottomAnchor.constraint(equalTo: currentTime.topAnchor, constant: -8),
            
            
            
        ])
    }
}

