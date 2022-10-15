//
//  RecordingViewController.swift
//  VideoRecorder
//
//  Created by 신동원 on 2022/10/11.
//

import UIKit
import AVFoundation
import Photos

//영상 녹화 화면
class RecordingViewController: UIViewController {
    
    let mainView = RecordingView()
    let captureSession = AVCaptureSession()
    var videoDevice: AVCaptureDevice!
    var audioDevice: AVCaptureDevice!
    var videoOutput: AVCaptureMovieFileOutput!
    var outputURL: URL?
    
    var timer: Timer?
    var timeCount = 0
    var albumTitle = "MyVideos"
    var myAlbum: PHAssetCollection!
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSession()
        DispatchQueue.main.async {
            self.requestPHPhotoLibraryAuthorization {
                //사진앨범 권한이 있을 경우
                if let album = self.searchMyAlbum() {
                    //앨범이 존재할때
                    self.myAlbum = album
                    self.makeAlbumImage()
                } else {
                    //앨범이 존재하지 않을때
                    self.createAlbum()
                }
                
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestCameraAuthorization()
    }
    
    func setupView() {
        //videoPreviewLayer의 session을 사용자 지정 세션으로 지정
        mainView.recordingView.videoPreviewLayer.session = self.captureSession
        let recordGesture = UITapGestureRecognizer(target: self, action: #selector(recordButtonClicked))
        mainView.recordButton.addGestureRecognizer(recordGesture)
        let changeGesture = UITapGestureRecognizer(target: self, action: #selector(changeCamera))
        mainView.cameraRotateButton.addGestureRecognizer(changeGesture)
        let albumGesture = UITapGestureRecognizer(target: self, action: #selector(albumButtonClicked))
        mainView.albumButton.addGestureRecognizer(albumGesture)
        
    }
    
    //버튼 클릭 시 isEnabled 값을 변경 true <-> false, 값에 따라 녹화 시작 or 종료
    @objc func recordButtonClicked() {
        mainView.recordButton.isEnabled = !mainView.recordButton.isEnabled
        
        if mainView.recordButton.isEnabled {
            startRecording()
        } else {
            stopRecording()
        }
        
    }
    //사진 앨범 키기
    @objc func albumButtonClicked() {
        guard let photoURL = NSURL(string: "photos-redirect://") else {
            return
        }
        UIApplication.shared.open(photoURL as URL)
    }
    
    
    func setupSession() {
        
        //퀄리티 high
        captureSession.sessionPreset = .high
        
        //세션 만들기 시작
        captureSession.beginConfiguration()
        
        //input 디바이스 선택 , 어떤 카메라를 쓸거야?
        videoDevice = bestDevice(in: .back) //기본은 back 포지션 카메라
        //카메라 디바이스 유무 확인, session에 input 할 수 있는지 확인
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice), captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        //오디오 디바이스 input
        audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        guard let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice), captureSession.canAddInput(audioDeviceInput) else { return }
        captureSession.addInput(audioDeviceInput)
        //output 선택 어디로 출력 할거야?
        videoOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        //세션 저장
        captureSession.commitConfiguration()
        
    }
    
    
    //녹화 시작
    private func startRecording() {
        mainView.cameraRotateButton.isUserInteractionEnabled = false
        outputURL = tempURL()
        startTimer()
        videoOutput.startRecording(to: outputURL!, recordingDelegate: self)
    }
    //녹화 종료
    private func stopRecording() {
        mainView.cameraRotateButton.isUserInteractionEnabled = true
        if videoOutput.isRecording {
            stopTimer()
            videoOutput.stopRecording()
        }
    }
    //타이머 시작
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.timeCount += 1
            self.mainView.timerLabel.text = Double(self.timeCount).format() //정수형을 hh:mm:ss 포맷으로 변경
        }
    }
    //타이머 종료 및 초기화
    private func stopTimer() {
        timer?.invalidate()
        self.timeCount = 0
        self.mainView.timerLabel.text = "00:00:00"
    }
    
    //카메라 포지션 변경 back -> front , front -> back
    @objc func changeCamera() {
        captureSession.beginConfiguration()
        guard let videoInput = captureSession.inputs[0] as? AVCaptureDeviceInput else { return }
        guard let audioInput = captureSession.inputs[1] as? AVCaptureDeviceInput else { return }
        
        var afterPosition: AVCaptureDevice.Position = .unspecified
        let position = videoInput.device.position
        
        if position == .back {
            afterPosition = .front
        } else {
            afterPosition = .back
        }
        let videoDevice = bestDevice(in: afterPosition)
        //이미 세션이 존재해 canAddInput는 항상 false 이기 때문에 세션 변경 시에는 예외처리를 하지 않는다
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice) else { return }
        
        captureSession.removeInput(videoInput)
        captureSession.addInput(videoDeviceInput)
        captureSession.removeInput(audioInput)
        captureSession.addInput(audioDeviceInput)
        
        captureSession.commitConfiguration()
        
    }
    
    //ios 원하는 포지션의 카메라중 가장 적합한 카메라를 골라준다
    private func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        let devices = discoverySession.devices
        guard !devices.isEmpty else { fatalError("Missing capture devices.")}
        
        return devices.first(where: { device in device.position == position })!
    }
    
    //녹화 영상 임시저장 공간
    //사진앨범에 저장하기 전 임시공간
    private func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let date = formatter.string(from: Date())
        
        if directory != "" {
            let path = directory.appendingPathComponent("MyVideo-" + date + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    //카메라 권한 요청
    func requestCameraAuthorization() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (status: Bool) in
            if status {
                print("Camera: 권한 허용")
                DispatchQueue.main.async {
                    self.mainView.recordButton.isUserInteractionEnabled = true
                    self.mainView.cameraRotateButton.isUserInteractionEnabled = true
                }
                self.requestAudioAuthorization()
                
            } else {
                print("Camera: 권한 거부")
                DispatchQueue.main.async {
                    self.mainView.recordButton.isUserInteractionEnabled = false
                    self.mainView.cameraRotateButton.isUserInteractionEnabled = false
                    self.goToSetting()
                }
                
            }
        })
    }
    
    //오디오 권한 요청
    func requestAudioAuthorization() {
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (status: Bool) in
            if status {
                print("audio: 권한 허용")
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                }
            } else {
                print("audio: 권한 거부")
                DispatchQueue.main.async {
                    self.mainView.recordButton.isUserInteractionEnabled = false
                    self.mainView.cameraRotateButton.isUserInteractionEnabled = false
                    self.goToSetting()
                }
            }
        })
    }
    
    //PHPhotoLibrary 권한 요청
    private func requestPHPhotoLibraryAuthorization(completion: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
            switch status {
            case .authorized:
                PHPhotoLibrary.shared().register(self)
                print("2번뷰 register")
                completion()
            case .denied:
                DispatchQueue.main.async {
                    self.mainView.albumButton.isUserInteractionEnabled = false
                    self.goToSetting()
                }
            default:
                break
            }
        }
    }
    
    //권한이 필요할 시 요청 알림 후 설정 화면으로 전환
    private func goToSetting() {
        let alert = UIAlertController(title: "권한 요청", message: "관련 권한을 허용해주세요", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))
        
        //권한 요청 알림창 취소 시 앱종료
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { _ in
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
        }))
        
        self.present(alert, animated: true)
        
    }
    
    //최근 동영상의 미리보기 이미지를 읽어와 image로 넣어준다
    private func makeAlbumImage() {
        let fetchOption = PHFetchOptions()
        fetchOption.fetchLimit = 1
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchPhotos = PHAsset.fetchAssets(in: myAlbum, options: fetchOption)
        if let photo = fetchPhotos.firstObject {
            DispatchQueue.main.async {
                ImageManager.shared.requestImage(from: photo, thumnailSize: self.mainView.albumButton.frame.size) { image in
                    self.mainView.albumButton.image = image
                }
            }
        } else {
            // 사진이 없을 때, 디폴트 이미지 지정, 앨범생성
            DispatchQueue.main.async {
                self.mainView.albumButton.image = UIImage(systemName: "photo")
            }
        }
    }
    
    //비디오 저장용 앨범 생성
    private func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumTitle)
        }) { success, error in
            if success {
                self.myAlbum = self.searchMyAlbum()
                self.makeAlbumImage()
            } else {
                print("error \(String(describing: error))")
            }
        }
    }
    
    //녹화된 비디오 저장
    private func saveVideo(url: URL) {
        PHPhotoLibrary.shared().performChanges({
            guard let album = self.myAlbum else { return }
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)!
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)// - 내가 만든 앨범(PHAssetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
        }) { (success, error) in
            
        }
    }
    //앨범이 존재하면 찾은 앨범을 return
    private func searchMyAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumTitle)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        guard let album: AnyObject = collection.firstObject else { return nil }
        return album as? PHAssetCollection
    }
}

extension RecordingViewController: AVCaptureFileOutputRecordingDelegate, PHPhotoLibraryChangeObserver {
    
    //갤러리에 변화가 감지되면 즉,녹화 영상이 저장되면 앨범 최신화
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        makeAlbumImage()
    }
    
    
    //영상 녹화가 종료됐을때
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            DispatchQueue.global(qos: .background).async {
                FirebaseStorage.shared.upload(url: outputFileURL)
            }
            saveVideo(url: outputFileURL)
        }
    }
    
}
