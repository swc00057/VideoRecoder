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
    
    let viewPlayerDetails: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let lblCurrentTime: UILabel = {
        let view = UILabel()
        view.text = "00.00"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let lblDurationTime: UILabel = {
        let view = UILabel()
        view.text = "00.00"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let sliderTime: UISlider = {
        let view = UISlider()
        view.minimumTrackTintColor = .yellow
        view.maximumTrackTintColor = .darkGray
        view.thumbTintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let btnMute: UIButton = {
        let view = UIButton()
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
        
        
        [videoView,viewPlayerDetails].forEach {
            containerView.addSubview($0)
        }
        
        [lblCurrentTime,lblDurationTime,sliderTime,btnMute].forEach {
            viewPlayerDetails.addSubview($0)
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
            
            viewPlayerDetails.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            viewPlayerDetails.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            viewPlayerDetails.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            viewPlayerDetails.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3),
            
            lblCurrentTime.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            lblCurrentTime.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            lblDurationTime.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            lblDurationTime.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            btnMute.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            btnMute.bottomAnchor.constraint(equalTo: lblCurrentTime.topAnchor, constant: -8),
            btnMute.widthAnchor.constraint(equalToConstant: 33),
            btnMute.heightAnchor.constraint(equalToConstant: 33),
            
            sliderTime.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            sliderTime.trailingAnchor.constraint(equalTo: btnMute.leadingAnchor, constant: -8),
            sliderTime.bottomAnchor.constraint(equalTo: lblCurrentTime.topAnchor, constant: -8),
            
            
            
        ])
    }
}

