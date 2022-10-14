//
//  RecordingView.swift
//  VideoRecorder
//
//  Created by 신동원 on 2022/10/12.
//

import UIKit
import AVFoundation

class RecordingView: UIView {
    
    lazy var recordingView: PreviewView = {
        let view = PreviewView()
        view.backgroundColor = .white
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let controlView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let albumButton: UIImageView = {
        let view = UIImageView()
        view.tintColor = .white
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let recordButton: RecordButton = {
        let view = RecordButton()
        view.image = UIImage(named: "record")
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let cameraRotateButton: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "camera.rotate")
        view.isUserInteractionEnabled = true
        view.tintColor = .white
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let timerLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.text = "00:00:00"
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
        addSubview(recordingView)
        addSubview(controlView)
        controlView.addSubview(albumButton)
        controlView.addSubview(recordButton)
        controlView.addSubview(cameraRotateButton)
        controlView.addSubview(timerLabel)
        
    }
    
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            recordingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            recordingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            recordingView.topAnchor.constraint(equalTo: topAnchor),
            recordingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            controlView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 32),
            controlView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -32),
            controlView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32),
            controlView.heightAnchor.constraint(equalTo: heightAnchor , multiplier: 0.15),
            
            albumButton.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 32),
            albumButton.centerYAnchor.constraint(equalTo: controlView.centerYAnchor),
            albumButton.widthAnchor.constraint(equalToConstant: 44),
            albumButton.heightAnchor.constraint(equalToConstant: 44),
            
            recordButton.centerXAnchor.constraint(equalTo: controlView.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: controlView.centerYAnchor, constant: -12),
            recordButton.widthAnchor.constraint(equalToConstant: 54),
            recordButton.heightAnchor.constraint(equalToConstant: 54),
            
            timerLabel.centerXAnchor.constraint(equalTo: controlView.centerXAnchor),
            timerLabel.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 6),
            
            cameraRotateButton.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -32),
            cameraRotateButton.centerYAnchor.constraint(equalTo: controlView.centerYAnchor),
            cameraRotateButton.widthAnchor.constraint(equalToConstant: 32),
            cameraRotateButton.heightAnchor.constraint(equalToConstant: 32)
            
            
        ])
    }
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

class RecordButton: UIImageView {
    
    var isEnabled = false {
        didSet {
            if isEnabled  {
                self.image = UIImage(named: "stop")
            } else {
                self.image = UIImage(named: "record")
            }
        }
    }
}
